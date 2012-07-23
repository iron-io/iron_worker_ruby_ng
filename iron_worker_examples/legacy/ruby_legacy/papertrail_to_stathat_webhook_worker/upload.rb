require 'iron_worker'
require 'time'
require_relative '../examples_helper'

require_relative 'stathat_webhook_worker'

@config = ExamplesHelper.load_config

IronWorker.configure do |config|
  config.token = @config['iw']['token']
  config.project_id = @config['iw']['project_id']
end


worker = StathatWebhookWorker.new
worker.upload

url = "https://worker-aws-us-east-1.iron.io/2/projects/#{@config['iw']['project_id']}/tasks/webhook?code_name=#{worker.class.name}&oauth=#{@config['iw']['token']}"
puts "Add this url to github Service Hooks, Post Receive URLs: "
puts url
