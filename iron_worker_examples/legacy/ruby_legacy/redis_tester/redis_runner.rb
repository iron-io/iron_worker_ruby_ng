require "iron_worker"
require "yaml"

require_relative "redis_worker"

config_data = YAML.load_file("../_config.yml")

IronWorker.configure do |config|
  config.token = config_data['iw']['token']
  config.project_id = config_data['iw']['project_id']
end

worker = RedisWorker.new
worker.redis_connection = config_data['redis_uri']

#worker.run_local

worker.queue
#worker.wait_until_complete
#puts worker.log

