require 'iron_worker'
require 'time'
require_relative '../examples_helper'

require_relative 'hipchat_poster_worker'

@config = ExamplesHelper.load_config

IronWorker.configure do |config|
  config.token = @config['iw']['token']
  config.project_id = @config['iw']['project_id']
end

delay = 0
10.times do |i|
  worker = HipchatPosterWorker.new
  worker.hipchat_api_key = @config['hipchat']['api_key']
  worker.hipchat_room_name = 'IronWorker'
  worker.twitter_keyword = "getiron"
  worker.n = i
  worker.delay = delay
  puts 'queuing with delay: ' + delay.to_s
  worker.queue(:delay=>delay)
  delay += 30 # add thirty seconds
end
