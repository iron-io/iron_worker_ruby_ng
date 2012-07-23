require 'iron_worker'
require 'time'
require_relative '../examples_helper'

require_relative 'twitter_to_hipchat_worker'

@config = ExamplesHelper.load_config

IronWorker.configure do |config|
  config.token = @config['iw']['token']
  config.project_id = @config['iw']['project_id']
end

worker = TwitterToHipchatWorker.new
worker.hipchat_api_key = @config['hipchat']['api_key']
worker.hipchat_room_name = @config['hipchat']['room_name']
worker.twitter_keyword = "getiron"

worker.queue
status = worker.wait_until_complete
puts worker.get_log

# to schedule:
# worker.schedule(:start_at=>Time.now.iso8601, :run_every=>3600*6)
