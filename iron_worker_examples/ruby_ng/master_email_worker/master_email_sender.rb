require 'yaml'
require 'iron_worker_ng'

#loading config
config_data = YAML.load_file '../../ruby/_config.yml'

#initializing IronMQ
ironmq = IronMQ::Client.new(:token => config_data['iw']['token'], :project_id => config_data['iw']['project_id'])

#adding emails to IronMQ queue
20.times do |i|
  ironmq.messages.post(config_data['email']['to'])
end


# Create an IronWorker client
client = IronWorkerNG::Client.new(:token => config_data['iw']['token'], :project_id => config_data['iw']['project_id'])

client.tasks.create("master_email_worker", config_data)
