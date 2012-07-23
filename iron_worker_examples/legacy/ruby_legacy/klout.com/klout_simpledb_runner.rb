
# Same as the MongoDB one but uses SimpleDB instead

require 'iron_worker'
require 'yaml'
require 'active_support/core_ext'

# Require_relative on the class name will also work
load "klout_simpledb_worker.rb"

config_data = YAML.load_file('../_config.yml')

IronWorker.configure do |config|
  config.token = config_data["iw"]["token"]
  config.project_id = config_data["iw"]["project_id"]
end

# Create the worker and set some attributes
worker = KloutSimpleDBWorker.new
worker.klout_api_key = config_data["klout"]["api_key"]
worker.klout_twitter_names = config_data["klout"]["twitter_names"]

worker.aws_access_key = config_data["aws"]["access_key"]
worker.aws_secret_key = config_data["aws"]["secret_key"]
worker.aws_sdb_domain_prefix = config_data["aws"]["sdb_domain_prefix"]

# Run the job (with several alternatives included)
worker.queue

#worker.run_local
#worker.schedule(:start_at => 2.minutes.since, :run_every => 60, :run_times => 2)
#worker.queue(:priority=>2)


# Go to the IronWorker dashboard to see the status and logs.

# You can also get the stats programmatically with the wait_until_complete and get_log
# Note that wait_until_complete only works with queue (not run_local or schedule).
status = worker.wait_until_complete
puts worker.get_log