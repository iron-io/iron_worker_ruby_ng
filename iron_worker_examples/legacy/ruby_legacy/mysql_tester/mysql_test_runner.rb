require 'iron_worker'
require 'yaml'

require_relative 'mysql_test_worker'

config_data = YAML.load_file('../_config.yml')

IronWorker.configure do |config|
  config.token = config_data['iw']['token']
  config.project_id = config_data['iw']['project_id']
end

worker = MySQLTestWorker.new 
worker.db_config = config_data['mysql']

#worker.run_local
worker.queue(:priority => 1)
