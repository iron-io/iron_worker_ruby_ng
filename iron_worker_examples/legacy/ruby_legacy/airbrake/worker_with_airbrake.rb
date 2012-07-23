#--
# Developed for www.iron.io
#
# WorkerWithAirbrake is a sample worker to show how easy it is to trigger an Airbrake exception on
# a worker error. It will trigger an airbrake exception and then reraise the error so that the IronWorker UI
# also knows and shows the error.
#
# You will need an account at Airbrake.com
#
# Find implementation info here: http://dev.iron.io/worker/articles/integrations/airbrake
#
#
# THESE EXAMPLES ARE INTENDED AS LEARNING AIDS FOR BUILDING WORKERS TO BE USED AT www.iron.io.
# THEY CAN BE USED IN YOUR OWN CODE AND MODIFIED AS YOU SEE FIT.
#
#++

require 'iron_worker'

class WorkerWithAirbrake < IronWorker::Base

  attr_accessor :api_key

  merge_gem 'airbrake'

  def run
    begin
      Airbrake.configure do |config|
        config.api_key = api_key
      end
      #--- YOUR WORKER CODE BELOW HERE ---




    rescue => ex
      Airbrake.notify(
        :error_class => "#{self.class}",
        :error_message => "#{ex} - #{ex.backtrace}"
      )
      puts "Error sent to Airbrake."
      raise ex
    end
  end
end