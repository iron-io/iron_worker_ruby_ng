
require 'iron_worker'
require 'yaml'

require_relative "deserialize_worker.rb"
 
config_data = YAML.load_file('../_config.yml')

IronWorker.configure do |config|
  config.token = config_data["iw"]["token"]
  config.project_id = config_data["iw"]["project_id"]
end

mg = ModelGood.new
mg.name = "Al Kaline"
mg.position = "RF"

mg2 = ModelGood2.new
mg2.name = "Bill Freehan"
mg2.position = "C"
mg2.bat_ave = 0.305

mng = ModelNoGood.new
mng.name = "Jim Northrup"
mng.position = "CF"

puts "\nJSON strings:"
p mg.to_json
p mg2.to_json
p mng.to_json
puts "\n"

worker = DeserializeWorker.new
worker.model_good = mg
worker.model_good2 = mg2
worker.model_no_good = mng

#worker.run_local

worker.queue

# Works with .queue only
status = worker.wait_until_complete
puts worker.get_log
