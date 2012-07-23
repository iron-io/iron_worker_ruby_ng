#--
# Copyright (c) 2011 www.iron.io
# Developer: Roman Kononov
#
# KloutSimpleDBWorker is a simple example of how the Klout API can be called from a Worker and the results
# stored into a SimpleDB domain (using SimpleRecord).  An example of this would be to
# go through your entire user base on a nightly basis, get the Klout score, and store it
# back into your own database.
# 
#++

require 'iron_worker'
require 'json'
require 'open-uri'
require 'rest-client'

class KloutSimpleDBWorker < IronWorker::Base

  merge_gem 'simple_record'
  
  # The model needs to be merged when running outside of Rails
  # Within Rails, models are merged automatically.
  #
  #merge File.join(File.dirname(__FILE__), 'user_klout_stat.rb')
  merge ('./user_klout_stat.rb')
  
  attr_accessor :klout_api_key, :klout_twitter_names,
                :aws_access_key, :aws_secret_key, :aws_sdb_domain_prefix

  def run
    log "Running Klout SimpleDBWorker..."

    init_simpledb

    # We only want to store the Klout for each user once per day - so this allows us to check
    today = Time.now.utc.at_beginning_of_day

    log "Updating Klout scores SimpleDBWorker..."
    # Iterate through the usernames passed into the worker from the runner (or your app)
    @klout_twitter_names.each do |username|
      begin
        # Call the Klout API
        response = RestClient.get 'http://api.klout.com/1/klout.json', {:params => {:key => @klout_api_key, :users=>username}}
        parsed = JSON.parse(response)

        # Check if there's a current score already set for today
        if daily_score = UserKloutStat.find(:first, :conditions=>["username=? and for_date=?", username, today])
          log "Existing daily score of #{daily_score.username}: #{daily_score.score}"
        else
          # Create if no score today
          daily_score = UserKloutStat.new(:username => username, :for_date => today, :score => 0) unless daily_score
          daily_score.score = parsed["users"][0]["kscore"] if parsed["users"] && parsed["users"][0]
          daily_score.save

          log "New daily score of #{daily_score.username}: #{daily_score.score}"
        end
      rescue =>ex
        log "EXCEPTION #{ex.inspect}"
      end
    end
    log "Finished updating Klout scores in SimpleDB."

    log "\nLogging Simple_Db records..."
    sdb_usernames = UserKloutStat.find(:all, :order=>"username", :limit=>50)
    sdb_usernames.each do |username|
      log "Twitter name  #{username.username}: #{username.score}   for date: " + username.for_date.strftime("%a %b %d, %Y")
    end

    UserKloutStat.close_connection
    log "Finished processing Klout SimpleDBWorker."
    
  end

  # Establish connection to SimpleDB
  def init_simpledb
    SimpleRecord.establish_connection(@aws_access_key, @aws_secret_key, :connection_mode=>:per_thread)
    SimpleRecord::Base.set_domain_prefix(@aws_sdb_domain_prefix)
  end

end

