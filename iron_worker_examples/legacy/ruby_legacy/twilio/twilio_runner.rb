require 'iron_worker'
require 'yaml'
require 'date'

require_relative 'twilio_sms_worker'
require_relative 'twilio_stats_worker'

config_data = YAML.load_file('../_config.yml')

IronWorker.configure do |config|
  config.token = config_data['iw']['token']
  config.project_id = config_data['iw']['project_id']
end

sms_worker = TwilioSMSWorker.new
sms_worker.sid = config_data['twilio']['sid']
sms_worker.token = config_data['twilio']['token']
sms_worker.api_version = config_data['twilio']['api_version']

# Set the phone number and message
sms_worker.from = config_data['twilio']['from']
sms_worker.to = config_data['twilio']['to']
sms_worker.message = config_data['twilio']['message'] + '  ' + Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')

#sms_worker.run_local
sms_worker.queue
status = sms_worker.wait_until_complete
puts sms_worker.get_log

# Now get some statistics
stats_worker = TwilioStatsWorker.new
stats_worker.sid = config_data['twilio']['sid']
stats_worker.token = config_data['twilio']['token']
stats_worker.api_version = config_data['twilio']['api_version']

#stats_worker.run_local
stats_worker.queue
#status = stats_worker.wait_until_complete
#puts stats_worker.get_log