require 'iron_worker_ng'
require 'uber_config'

@config = UberConfig.load
@iw = IronWorkerNG::Client.new

# delay is the number of seconds to wait before running the task
delay = 0
ARGV.each do |a|
  puts "Argument: #{a}"
  delay = a.to_i
end

@iw.tasks.create("sms", @config, {:delay=>delay})
