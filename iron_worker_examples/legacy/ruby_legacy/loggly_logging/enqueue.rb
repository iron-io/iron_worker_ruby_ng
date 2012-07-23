require 'iron_worker'
require 'time'
require_relative '../examples_helper'

require_relative 'loggly_worker'

@config = ExamplesHelper.load_config

IronWorker.configure do |config|
  config.token = @config['iw']['token']
  config.project_id = @config['iw']['project_id']
end

50.times do |i|
  worker = LogglyWorker.new
  worker.loggly_key = @config['loggly']['key']
  worker.i = i
  worker.queue()
end

