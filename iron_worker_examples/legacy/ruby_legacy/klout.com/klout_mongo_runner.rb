#
# This is a mashup of the Klout HelloWorker example and the MongoWorker example.
#
# TO USE:
# Get accounts/credentials for IronWorker, Klout, and Mongo and replace the
# placeholders in the _config.yml file. Modify/add to the twitter names, and
# then then run this file.
#

require 'iron_worker'
require 'yaml'
require 'active_support/core_ext'

# Require_relative on the class name will also work
load 'klout_mongo_worker.rb'

config_data = YAML.load_file('../_config.yml')

IronWorker.configure do |config|
  config.token = config_data['iw']['token']
  config.project_id = config_data['iw']['project_id']
end

# Create the worker and set some attributes
worker = KloutMongoWorker.new
worker.klout_api_key = config_data['klout']['api_key']
worker.klout_twitter_names = config_data['klout']['twitter_names']

worker.mongo_host      = config_data['mongo']['host']
worker.mongo_port      = config_data['mongo']['port']
worker.mongo_db_name   = config_data['mongo']['db_name']
worker.mongo_username  = config_data['mongo']['username']
worker.mongo_password  = config_data['mongo']['password']

# Run the task.
#worker.queue(:priority=>1)

worker.run_local
#worker.schedule(:start_at => 2.minutes.since, :run_every => 60, :run_times => 2)
#worker.queue(:priority=>2)


# Go to the IronWorker dashboard to see the status and logs.

# You can also get the stats programmatically with the wait_until_complete and get_log
# Note that wait_until_complete only works with queue (not run_local or schedule).
status = worker.wait_until_complete
puts worker.get_log


