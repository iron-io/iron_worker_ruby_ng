#--
# Master_Runner
#
# Puts a master worker in a schedule. This master worker will, when 
# it runs, queue up a set of slave workers. In this case, the slave
# workers will use the Klout_Hello_Worker to get Klout scores.
#

require 'iron_worker'
require 'yaml'
require 'active_support/core_ext'

require_relative 'master_worker'

config_data = YAML.load_file('../_config.yml')

IronWorker.configure do |config|
  config.token = config_data['iw']['token']
  config.project_id = config_data['iw']['project_id']
end

# Create the worker and set some attributes
# Pass off up to slice_num of names per worker
worker = MasterWorker.new
worker.klout_api_key = config_data['klout']['api_key']
worker.klout_twitter_names = config_data['klout']['twitter_names']
worker.slice_num = 3

# Debug with these.
#worker.run_local
worker.queue(:priority=>1)

# This schedules the task 2 times, 3 minutes apart. For a production
# task, it'd likely be spread apart and run on a recurring basis.
#worker.schedule(:start_at => 2.minutes.since, :run_every => 180, :run_times => 2)

