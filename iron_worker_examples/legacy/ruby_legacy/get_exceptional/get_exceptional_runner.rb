require 'iron_worker'
require "yaml"

load "get_exceptional_worker.rb"

config_data = YAML.load_file('../_config.yml')

IronWorker.configure do |config|
  config.token = config_data["iw"]["token"]
  config.project_id = config_data["iw"]["project_id"]
end

worker = GetExceptionalWorker.new
worker.api_key = config_data["get_exceptional"]["api_key"]

#worker.run_local
worker.queue(:priority=>1)

worker.wait_until_complete
