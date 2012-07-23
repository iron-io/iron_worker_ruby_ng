require 'iron_worker'

load "pagerduty_worker.rb"

IronWorker.configure do |config|
  config.token = TOKEN
  config.project_id = PROJECT_ID
end

worker = PagerdutyWorker.new
worker.api_key = YOUR_PAGERDUTY_API_KEY
worker.queue