#--
# Developed for www.iron.io
#
# AnalyticsWorker is an example worker to show how to easily connect ot the Google analytics API
#
# Possible use case: This worker can easily be scheduled to run nightly to pull information from Google Analytics
#
#
# THESE EXAMPLES ARE INTENDED AS LEARNING AIDS FOR BUILDING WORKERS TO BE USED AT www.iron.io.
# THEY CAN BE USED IN YOUR OWN CODE AND MODIFIED AS YOU SEE FIT.
#
#++

require 'iron_worker'
require 'active_support/core_ext'

class AnalyticsWorker < IronWorker::Base

  merge_gem "mongoid"
  merge_gem "garb"

  attr_accessor :config, :num_days

  def run
    setup_database
    setup_google_api

    start_date = Time.now.beginning_of_day
    end_date = Time.now.end_of_day

    puts "============ Starting Analytics worker ==========="
    x=0
    while x < num_days
      start_date -= 1.days
      end_date -= 1.days

      puts "\n\n-- Getting data for #{start_date.to_date} --"

      get_visits(start_date, end_date)

      x += 1
    end

    puts "Done running analytics worker!"
  end


  private


  def get_visits(start_date, end_date)
    report = Garb::Report.new(@profile, {:metrics => [:visits], :start_date => start_date, :end_date => end_date})
    visits = report.results.first.visits unless report.results.nil? || report.results.first.nil?
  end


  def setup_google_api
    Garb::Session.login(GOOGLE_USER_LOGIN, GOOGLE_USER_PASS)

    # There are two ways to use the Garb gem

    # ----- First Way
    #Garb::Management::Profile.all
    #Garb::Management::WebProperty.all
    #@profile = Garb::Management::Profile.all
    #@data = @profile.analytics(:filters => {:page_path.eql => '/'}, :start_date => start_date, :end_date => end_date)

    # ----- Second Way
    # Get all profiles that match that property ID (Might be only one)
    @profiles = Garb::Profile.all.select { |p| p.web_property_id == 'UA-XXXXXXX-Y' }

    # Get the MAIN profile (Only need this if you have multiple profiles)
    @profile = @profiles.detect { |p| p.title == "MAIN" }
  end

  def setup_database
    Mongoid.configure do |c|
      c.logger.level = Logger::DEBUG
      c.from_hash(config['mongo'])
    end
  end
end
