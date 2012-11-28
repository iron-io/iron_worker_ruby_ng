require 'open-uri'
require 'nokogiri'
require 'iron_worker_ng'
require 'iron_cache'
require 'iron_mq'

load 'url_utils.rb'

include UrlUtils

def process_page(url)
  puts "Processing page #{url}"
  #adding url to cache
  @iron_cache_client.items.put(CGI::escape(url), {:status => "found"}.to_json)
  #pushing url to iron_mq to process page
  result = @iron_mq_client.messages.post(CGI::escape(url))
  puts "Message put in queue #{result}"
end

def crawl_domain(url, depth)
  url_object = open_url(url)
  #returning if url is empty
  return if url_object == nil
  parsed_url = parse_url(url_object)
  #trying to parse url and returning if parsed url is nil
  return if parsed_url == nil
  #all good, scanning url for links
  puts "Scanning URL:#{url}"
  page_urls = find_urls_on_page(parsed_url, url)
  puts "FOUND links:#{page_urls.count}"

  page_urls.each_with_index do |page_url, index|
    if urls_on_same_domain?(url, page_url)
      pages_count = @iron_cache_client.items.get('pages_count').value
      puts "Pages scanned:#{pages_count}"
      puts "Page url #{page_url},index:#{index}"

      #incrementing page counts
      @iron_cache_client.items.put('pages_count', pages_count + 1)

      return if pages_count >= params['page_limit']
      puts "current depth:#{depth}"
      #getting page from cache
      page_from_cache = @iron_cache_client.items.get(CGI::escape(page_url))

      if page_from_cache.nil?
        #page not processed yet so lets process it and queue worker if possible
        process_page(page_url) if open_url(page_url)
        queue_worker(depth, page_url) if depth > 1
      else
        puts "Link #{page_url} already processed, bypassing"
        #page_from_cache.delete
      end
    end
  end
end

def queue_worker(depth, page_url)
  p = {:url => page_url,
       :page_limit => params["page_limit"],
       :depth => depth - 1,
       :max_workers => params["max_workers"],
       :iw_token => params["iw_token"],
       :iw_project_id => params["iw_project_id"]
  }
  #queueing child worker or processing page in same worker
  workers_count = @iron_cache_client.items.get('workers_count')
  count = workers_count ? workers_count.value : 0
  puts "Number of workers:#{count}"
  if count < params['max_workers'] - 1
    #launcing new worker
    @iron_cache_client.items.put('workers_count', count+1)
    @iron_worker_client.tasks.create("WebCrawler", p)
  else
    #processing in same worker - too many workers running
    crawl_domain(page_url, depth-1)
  end
  @iron_worker_client.tasks.create("PageProcessor", p)
end

#initializing IW an Iron Cache
@iron_cache_client = IronCache::Client.new({"token" => params['iw_token'], "project_id" => params['iw_project_id']})
@iron_worker_client = IronWorkerNG::Client.new(:token => params['iw_token'], :project_id => params['iw_project_id'])
@iron_mq_client = IronMQ::Client.new(:token => params['iw_token'], :project_id => params['iw_project_id'])

#start crawling
crawl_domain(params['url'], params['depth']||1)

#decreasing number of workers - we need this in slave workers to say that this worker finish his work
# and system could queue new one

workers_count = @iron_cache_client.items.get('workers_count')
count = workers_count ? workers_count.value : 0
@iron_cache_client.items.put('workers_count', count-1) if count > 0