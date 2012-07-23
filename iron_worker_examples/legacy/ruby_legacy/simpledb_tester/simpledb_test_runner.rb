require 'iron_worker'
require 'yaml'

require_relative 'simpledb_test_worker'

config_data = YAML.load_file '../_config.yml'

IronWorker.configure do |config|
  config.token = config_data['iw']['token']
  config.project_id = config_data['iw']['project_id']
end

worker = SimpleDBTestWorker.new
worker.aws_access = config_data['aws']['access_key']
worker.aws_secret = config_data['aws']['secret_key']

#worker.run_local
worker.queue(:priority => 2)
status = worker.wait_until_complete
puts worker.get_log
