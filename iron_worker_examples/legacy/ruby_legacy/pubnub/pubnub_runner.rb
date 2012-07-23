require 'iron_worker'
require 'yaml'
require 'date'

require_relative 'pubnub_worker'

config_data = YAML.load_file('../_config.yml')

# IronWorker configure
IronWorker.configure do |config|
  config.token = config_data['iw']['token']
  config.project_id = config_data['iw']['project_id']
end

secrets = {
  :publish => config_data['pubnub']['publish'],
  :subscribe => config_data['pubnub']['subscribe'],
  :secret => config_data['pubnub']['secret']
}
channel = config_data['pubnub']['channel']
            
worker = PubNubWorker.new
worker.secrets = secrets
worker.channel = channel
worker.message = config_data['pubnub']['message'] + "  " + Time.now.strftime("%a, %e %b %Y %H:%M:%S %z")

#worker.run_local
worker.queue
status = worker.wait_until_complete
puts worker.get_log


# Print out the messages
begin
  pubnub = Pubnub.new(secrets[:publish], secrets[:subscribe], secrets[:secret], true)
  messages = pubnub.history ({
    'channel' => channel,
    'limit'   => 10
    })
  puts messages
rescue => ex
  puts "Exception: #{ex.message}"
  raise ex
end



