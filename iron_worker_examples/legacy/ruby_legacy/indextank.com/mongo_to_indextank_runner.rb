# TO USE:
# This example builds on the MongoDB example so check out that one first.
#
# Get accounts/credentials for IronWorker, IndexTank (being deprecated), and
# a MongoDB (MongoHQ is pretty cool) and place in the _config.yml file. Then
# run this file.
#

require 'iron_worker'
require 'yaml'
require "active_support/core_ext"

require_relative "mongo_to_indextank_worker.rb"

config_data = YAML.load_file('../_config.yml')

IronWorker.configure do |config|
  config.token = config_data["iw"]["token"]``
  config.project_id = config_data["iw"]["project_id"]
end

# These params are included here to make it simple to get
# the example running. Some could go in the worker directly.
worker = MongoToIndextankWorker.new

worker.mongo_host   = config_data['mongo2']['host']
worker.mongo_port = config_data['mongo2']['port']
worker.mongo_db_name = config_data['mongo2']['db_name']
worker.mongo_username = config_data['mongo2']['username']
worker.mongo_password = config_data['mongo2']['password']

worker.indextank_url = config_data['indextank']['_url']
worker.indextank_index = config_data['indextank']['index']

# Run the task (several alternatives included)
#worker.queue

worker.run_local
#worker.queue(:priority=>2)
#worker.schedule(:start_at => 2.minutes.since, :run_every => 60, :run_times => 2)

# Go to the IronWorker dashboard to see the status and logs.

# You can also get the stats programmatically with the wait_until_complete and get_log
# Note that wait_until_complete only works with queue (not run_local or schedule).
#
status = worker.wait_until_complete
puts worker.get_log

