require 'yaml'
require 'iron_worker_ng'

# loading config from config file
config_data = YAML.load_file '../../ruby/_config.yml'

# Create an IronWorker client
client = IronWorkerNG::Client.new(:token => config_data['iw']['token'], :project_id => config_data['iw']['project_id'])

twilio = config_data['twilio']

params = {:sid => twilio['sid'],
          :token => twilio['token'],
          :from => twilio['from'],
          :to => twilio['to'],
          :message => 'sample'
}
#launching worker
client.tasks.create("twilio_worker", params)
