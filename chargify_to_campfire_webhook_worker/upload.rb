require 'iron_worker_ng'
require_relative '../../ruby/examples_helper'
config = ExamplesHelper.load_config

# Create an IronWorker client
client = IronWorkerNG::Client.new(:token => config['iw']['token'], :project_id => config['iw']['project_id'])

# Create our code package containing the webhook
code = IronWorkerNG::Code::Ruby.new(:exec=>'chargify_to_campfire_webhook_worker.rb')
code.merge_file 'webhook_config.yml'
code.merge_gem 'broach'

# Upload the code package
client.codes.create(code)

url = "https://worker-aws-us-east-1.iron.io/2/projects/#{config['iw']['project_id']}/tasks/webhook?code_name=#{code.name}&oauth=#{config['iw']['token']}"

puts "Add the following url to Github Service Hooks, Post Receive URLs: "
puts url
