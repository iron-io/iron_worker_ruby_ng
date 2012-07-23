#--
# Klout_Hello_Worker_Runner
# Developer: Roman Kononov / Ken Fromm
#
# TO USE:
# Get accounts/credentials for IronWorker and Klout and then replace the
# placeholders in the _config.yml file. Modify/add to the twitter names, and
# then then run this file.
#

require 'iron_worker'
require 'yaml'
# Needed for scheduling 'minutes_since' syntax
require 'active_support/core_ext'

require_relative 'klout_hello_worker'

config_data = YAML.load_file('../_config.yml')

IronWorker.configure do |config|
  config.token = config_data['iw']['token']
  config.project_id = config_data['iw']['project_id']
end

# Create the worker and set some attributes
worker = KloutHelloWorker.new
worker.klout_api_key = config_data['klout']['api_key']
worker.klout_twitter_names = config_data['klout']['twitter_names']

# Run the task.
worker.queue(:priority=>1)

# Several alternatives ways to run the task as well.
#worker.run_local
#worker.schedule(:start_at => 2.minutes.since, :run_every => 60, :run_times => 2)
#worker.queue

# Go to the IronWorker dashboard to see the status and logs.

# You can also get the stats programmatically with the wait_until_complete and get_log
# Note that wait_until_complete only works with queue (not run_local or schedule).
status = worker.wait_until_complete
puts worker.get_log
