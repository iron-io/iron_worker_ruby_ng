require 'iron_worker_ng'
require 'iron_cache'
require "yaml"

@config_data = YAML.load_file("../_config.yml")

def params
  {'url' => 'http://www.meetup.com/sfrails/',
   'page_limit' => 1000,
   'depth' => 3,
   'max_workers' => 50,
   'iw_token' => @config_data['iw']['token'],
   'iw_project_id' => @config_data['iw']['project_id']}
end


ng_client = IronWorkerNG::Client.new(:token => params['iw_token'], :project_id => params['iw_project_id'])
#cleaning up cache
cache = IronCache::Client.new({"token" => params['iw_token'], "project_id" => params['iw_project_id']})
cache.items.put('pages_count', 0)
#launching worker
puts "Launching crawler"
ng_client.tasks.create("WebCrawler", params)
puts "Crawler launched! now open http://hud.iron.io"