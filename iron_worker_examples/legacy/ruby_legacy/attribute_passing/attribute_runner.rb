require 'iron_worker'
 
require 'yaml'
require 'date'
require 'active_support/core_ext'
require 'json'

require_relative 'attribute_worker.rb'

config_data = YAML.load_file('../_config.yml')

IronWorker.configure do |config|
  config.token = config_data["iw"]["token"]
  config.project_id = config_data["iw"]["project_id"]
end

string_hash = '{"messages":[{"msg_id":"12345"},{"msg_id":"67890"}],"page":0,"num_pages":1,"page_size":50,"total":5,"start":0}'

worker = AttributeWorker.new
worker.fixnum_arg = 27
worker.floatnum_arg = 3.3333
worker.array_arg = 5.times.map{ 0+Random.rand(99) }.sort 
worker.array_arg = [57, 121, 149, 288, 333]
worker.string_arg = "Here's a string."
worker.string_hash_arg = string_hash
worker.hash_arg = { "user" => { "name" => { "first" => "Bob", "last" => "Smith" } } }
worker.symbol_arg = { :a => "alpha", :b => "bravo", :c => "charlie"}
worker.time_arg = Time.new.utc
worker.time_string_arg = worker.time_arg.to_s
worker.time_int_arg = worker.time_arg.to_i

#worker.run_local
worker.queue(:priority=>1)
#worker.schedule(:start_at => 2.minutes.since, :run_every => 60, :run_times => 10)

puts "\n"
puts "@fixnum_arg: #{worker.fixnum_arg}  [#{worker.fixnum_arg.class}]"
puts "@floatnum_arg: #{worker.floatnum_arg}  [#{worker.floatnum_arg.class}]"
puts "@array_arg: #{worker.array_arg}  [#{worker.array_arg.class}]"
puts "\n@string_arg: #{worker.string_arg}  [#{worker.string_arg.class}]"
puts "@string_hash_arg: #{worker.string_hash_arg}  [#{worker.string_hash_arg.class}]"
puts "\n@hash_arg: #{worker.hash_arg}  [#{worker.hash_arg.class}]"
puts "@symbol_arg: #{worker.symbol_arg}  [#{worker.symbol_arg.class}]"
puts "\n@time_arg: #{worker.time_arg}  [#{worker.time_arg.class}]"
puts "\n@time_string_arg: #{worker.time_string_arg}  [#{worker.time_string_arg.class}]"
puts "@time_int_arg: #{worker.time_int_arg}  [#{worker.time_int_arg.class}]"
puts "\n"

# This works with queue
status = worker.wait_until_complete
puts worker.get_log
