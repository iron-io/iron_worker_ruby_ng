require 'iron_worker'
require 'yaml'
require 'active_support/core_ext'

require_relative "twitter_worker"

config_data = YAML.load_file('../_config.yml')

IronWorker.configure do |config|
  config.token = config_data['iw']['token']
  config.project_id = config_data['iw']['project_id']
end

worker = TwitterWorker.new
worker.twitter_config = {
    :consumer_key => config_data['twitter']['consumer_key'],
    :consumer_secret => config_data['twitter']['consumer_secret'],
    :oauth_token => config_data['twitter']['oauth_token'],
    :oauth_token_secret => config_data['twitter']['oauth_token_secret']
}
worker.message = config_data['twitter']['message']

worker.queue(:priority => 2)

worker.schedule(:start_at => 1.minutes.from_now,
           :run_every => 60, # seconds
           :run_times => 3,
           :priority => 2)