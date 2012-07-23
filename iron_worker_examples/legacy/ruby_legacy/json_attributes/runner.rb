require 'yaml'
require 'iron_worker'
require_relative "json_attr_worker.rb"

config_data = YAML.load_file('../_config.yml')

IronWorker.configure do |config|
  config.token = config_data["iw"]["token"]
  config.project_id = config_data["iw"]["project_id"]
end

mm = MyModel.new
mm.name = "Travis"
mm.age = 99

worker = JsonAttrWorker.new
worker.object = mm
worker.queue

status = worker.wait_until_complete
puts "LOG:"
puts worker.get_log
