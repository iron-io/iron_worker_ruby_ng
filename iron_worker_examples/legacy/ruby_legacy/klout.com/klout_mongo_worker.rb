#--
# KloutMongoWorker is a simple example of how the Klout API can be called from a Worker and the results
# stored into a MongoHQ DB (using Mongoid). An example of this would be to go through the user base
# on a nightly basis, get the Klout score, and store it back into your own database.
#
#++

require 'iron_worker'
require 'json'
require 'open-uri'
require 'rest-client'

class KloutMongoWorker < IronWorker::Base

  merge_gem 'mongoid'

  merge File.join(File.dirname(__FILE__), 'user_klout_mongo_stat.rb')
  attr_accessor :klout_api_key, :klout_twitter_names,
                :mongo_host, :mongo_port, :mongo_db_name, :mongo_username, :mongo_password

  def run
    log "Running Klout MongoWorker..."

    init_mongohq

    # We only want to store the Klout for each user once per day - so this allows us to check
    today = Time.now.utc.at_beginning_of_day

    # Iterate through the usernames passed into the worker from the runner (or your app)
    # One optimization is to send the set of usernames (change param to :users=>twitter_usernames.join(","))
    # and adjust the loop to work on the returned set.

    @klout_twitter_names.each do |username|
      begin
        # Check if there's a current score already set for today
        if daily_score = UserKloutMongoStat.first(conditions: {username: username, for_date: today})
          log "Existing daily score of #{daily_score.username}: #{daily_score.score}"
        else
          # If a daily score record doesn't exist, call the Klout API and create one
          response = RestClient.get 'http://api.klout.com/1/klout.json', {:params => {:key => @klout_api_key, :users=>username}}
          parsed = JSON.parse(response)

          daily_score = UserKloutMongoStat.new(:username => username, :for_date => today, :score => 0)
          daily_score.score = parsed['users'][0]['kscore'] if parsed['users'] && parsed['users'][0]
          daily_score.save

          log "New daily score of #{daily_score.username}: #{daily_score.score}"
        end

      rescue =>ex
        # If no username, .RestClient.get will return: 404 Resource Not Found.
        log "EXCEPTION #{ex.inspect}"
      end
    end

    puts "Done processing Klout MongoWorker."
  end

  # Configures settings for MongoDB. Values for mongo_host and mongo_port passed in to
  # make the example easy to understand. Could be placed directly inline to streamline.
  def init_mongohq
    Mongoid.configure do |config|
      config.database = Mongo::Connection.new(mongo_host, mongo_port).db(mongo_db_name)
      config.database.authenticate(mongo_username, mongo_password)
#      config.slaves = [
#          Mongo::Connection.new(host, 27018, :slave_ok => true).db(name)
#      ]
      config.persist_in_safe_mode = false
    end
  end

end

