# TO USE:
# 1) Get accounts/credentials for IronWorker and a MongoDB (MongoHQ is pretty cool).
#

require 'iron_worker'
require 'yaml'
# This is needed for the 'minutes since' syntax
require 'active_support/core_ext'

require_relative 'mongo_worker.rb'

config_data = YAML.load_file('../_config.yml')

IronWorker.configure do |config|
  config.token = config_data['iw']['token']
  config.project_id = config_data['iw']['project_id']
end

mw               = MongoWorker.new

# Run the job (with several alternatives included)
#mw.queue
mw.run_local
#mw.schedule(:start_at => 2.minutes.since, :run_every => 60, :run_times => 2)
#mw.queue(:priority=>2)

# Go to the IronWorker dashboard to see the status and logs.

# You can also get the stats programmatically with the wait_until_complete and get_log
# Note that wait_until_complete only works with queue (not run_local or schedule).
status = mw.wait_until_complete
puts mw.get_log
