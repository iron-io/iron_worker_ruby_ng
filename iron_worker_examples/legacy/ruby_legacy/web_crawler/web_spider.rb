require 'net/http'
require 'uri'
require 'open-uri'
require 'hpricot'
require 'iron_worker'

class WebSpider < IronWorker::Base
  merge_gem "redis"
  merge 'url_utils'
  attr_accessor :url, :page_limit, :depth, :redis_connection, :max_workers

  include UrlUtils

  def run
    @redis = configure_redis
    puts "URL:#{url}"
    crawl_domain(url, depth||1)
    count = @redis.get("workers_count").to_i
    @redis.set("workers_count", count - 1) if count > 0
  end

  def configure_redis
    url = URI.parse(@redis_connection)
    log "\nConnecting to Redis..."
    Redis.new(:host => url.host, :port => url.port, :password => url.password)
  end

  def crawl_domain(url, depth)
    url_object = open_url(url)
    return if url_object == nil
    parsed_url = parse_url(url_object)
    return if parsed_url == nil
    @redis.set(url, true) unless @redis.get(url)
    page_urls = find_urls_on_page(parsed_url, url)
    puts "FOUND links:#{page_urls.count}"
    page_urls.each do |page_url|
      return if @redis.keys.count >= page_limit
      puts "PAGE_URL:#{page_url} PAGE EXIST:#{@redis.get(page_url)||"no"}"
      if urls_on_same_domain?(url, page_url)
        puts "DEPTH:#{depth}"
        if depth > 1 && !(@redis.get(page_url) && @redis.get(page_url)=="browsed")
          @redis.set(page_url, "browsed")
          puts "queue worker #{page_url}"
          queue_worker(depth, page_url)
        else
          @redis.set(page_url, "found")
        end
      end
    end
  end

  def queue_worker(depth, page_url)
    count = @redis.get("workers_count").to_i
    if count < max_workers - 1
      @redis.set("workers_count", count+1)
      worker = WebSpider.new
      worker.url = page_url
      worker.page_limit = page_limit
      worker.max_workers = max_workers
      worker.depth = depth - 1
      worker.redis_connection = redis_connection
      worker.queue(:recursive => true)
    else
      crawl_domain(url, depth-1)
    end
  end

  private

  def open_url(url)
    url_object = nil
    begin
      url_object = open(url)
    rescue
      puts "Unable to open url: " + url
    end
    url_object
  end

  def update_url_if_redirected(url, url_object)
    if url != url_object.base_uri.to_s
      return url_object.base_uri.to_s
    end
    url
  end

  def parse_url(url_object)
    doc = nil
    begin
      doc = Hpricot(url_object)
    rescue
      puts 'Could not parse url: ' + url_object.base_uri.to_s
    end
    puts 'Crawling url ' + url_object.base_uri.to_s
    doc
  end

  def find_urls_on_page(parsed_url, current_url)
    urls_list = []
    begin
      parsed_url.search('a[@href]').map do |x|
        new_url = x['href'].split('#')[0]
        unless new_url == nil
          if relative?(new_url)
            new_url = make_absolute(current_url, new_url)
          end
          urls_list.push(new_url)
        end
      end
    rescue
      puts "could not find links"
    end
    urls_list
  end

end


    

