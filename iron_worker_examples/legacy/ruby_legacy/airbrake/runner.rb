require 'iron_worker'
require "yaml"

load "worker_with_airbrake.rb"

IronWorker.configure do |config|
  config.token = TOKEN
  config.project_id = PROJECT_ID
end

worker = WorkerWithAirbrake.new
worker.api_key = AIRBRAKE_API_KEY

worker.queue