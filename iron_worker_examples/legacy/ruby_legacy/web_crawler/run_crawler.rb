require 'iron_worker'
require "yaml"

config_data = YAML.load_file("../_config.yml")

IronWorker.configure do |config|
  config.token = config_data['iw']['token']
  config.project_id = config_data['iw']['project_id']
end


require_relative 'web_spider'

spider = WebSpider.new
spider.url = 'http://sample.com'
spider.page_limit = 1000
spider.depth = 3
spider.max_workers = 2
spider.redis_connection = config_data['redis_uri']
spider.queue(:recursive=>true)