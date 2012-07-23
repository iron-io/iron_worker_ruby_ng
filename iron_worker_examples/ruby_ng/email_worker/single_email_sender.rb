require 'yaml'
require 'iron_worker_ng'

# loading config from config file
config_data = YAML.load_file '../../ruby/_config.yml'
#also you could just create iron.json config file in your home directory and don't load anything

# Create an IronWorker client
client = IronWorkerNG::Client.new(:token => config_data['iw']['token'], :project_id => config_data['iw']['project_id'])

email = config_data['email']
#general params
params = {:username => email['username'],
          :password => email['password'],
          :domain => email['domain'],
          :provider => 'gmail'
}
#individual params
params.merge!({
                  :from => email['from'],
                  :to => [email['to'],email['to']],
                  :subject => 'sample',
                  :content => 'HEY ITs a body'
              })
#launching worker
client.tasks.create("email_worker", params)
