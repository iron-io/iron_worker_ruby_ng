#--
# www.iron.io
# Developer: Roman Kononov / Ken Fromm
#
# Klout_HelloWorker is a simple example of how to connect a worker to the Klout API.
#
# There is a klout.rb gem that has some nice methods and error checking but this
# makes the API call directly so you can see the formats.
#
# A set of usernames can be obtained by changing the API param to :users=>twitter_names.join(',')
# Of course, you'd want to take out or modify the twitter_usernames do loop.
#
#++

require 'iron_worker'
require 'json'
require 'open-uri'
require 'rest-client'

class KloutHelloWorker < IronWorker::Base

  attr_accessor :klout_api_key, :klout_twitter_names

  def run
    log "\nRunning Klout HelloWorker..."

    @klout_twitter_names.each do |username|
      begin
        # Call the Klout API
        response = RestClient.get 'http://api.klout.com/1/klout.json', {:params => {:key => @klout_api_key, :users=>username}}
        parsed = JSON.parse(response)

        daily_score = parsed['users'][0]['kscore'] if parsed['users'] && parsed['users'][0]

        log "Processing: #{username}  Score: #{daily_score}"

      rescue =>ex
        puts "EXCEPTION #{ex.inspect}"
      end
    end

    puts "Done processing Klout HelloWorker.\n\n"
  end

end
