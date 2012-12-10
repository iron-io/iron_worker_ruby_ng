require 'open-uri'
require 'nokogiri'
require 'iron_cache'
require 'iron_mq'

def make_absolute(href, root)
  return unless href
  puts "Making absolute:#{href} with root:#{root}"
  URI.parse(root).merge(URI.parse(href)).to_s rescue nil
end

def process_images(doc)
  #get all images
  images = doc.css("img")
  #get image with highest height on page
  largest_image = doc.search("img").sort_by { |img| img["height"].to_i }[-1]
  largest_image = largest_image ? largest_image['src'] : 'none'
  list_of_images = doc.search("img").map { |img| img["src"] }
  return images, largest_image, list_of_images
end

def process_links(doc)
  #get all links
  links = doc.css("a")
end

def process_css(doc)
  #find all css includes
  css = doc.search("[@type='text/css']")
end

def process_words(doc)
  #converting to plain text and removing tags
  text = doc.text
  #splitting by words
  words = text.split(/[^a-zA-Z]/)
  #removing empty string
  words.delete_if { |e| e.empty? }
  #creating hash
  freqs = Hash.new(0)
  #calculating stats
  words.each { |word| freqs[word] += 1 }
  freqs.sort_by { |x, y| y }
end

def process_page(url)
  puts "Processing page #{url}"
  doc = Nokogiri(open(url))
  images, largest_image, list_of_images = process_images(doc)
  #processing links an making them absolute
  links = process_links(doc).map { |link| make_absolute(link['href'], url) }.compact
  css = process_css(doc)
  words_stat = process_words(doc)
  puts "Number of images on page:#{images.count}"
  puts "Number of css on page:#{css.count}"
  puts "Number of links on page:#{links.count}"
  puts "Largest image on page:#{largest_image}"
  puts "Words frequency:#{words_stat.inspect}"
  #putting all in cache
  @iron_cache_client.items.put(CGI::escape(url), {:status => "processed",
                                                  :number_of_images => images.count,
                                                  :largest_image => CGI::escape(largest_image),
                                                  :number_of_css => css.count,
                                                  :number_of_links => links.count,
                                                  :list_of_images => list_of_images,
                                                  :words_stat => words_stat,
                                                  :timestamp => Time.now,
                                                  :processed_counter => 1}.to_json)

end

def get_list_of_messages
  #100 pages per worker at max
  max_number_of_urls = 100
  puts "Getting messages from IronMQ"
  messages = @iron_mq_client.messages.get(:n => max_number_of_urls, :timeout => 100)
  puts "Got messages from queue - #{messages.count}"
  messages
end

def increment_counter(url, cache_item)
  puts "Page already processed, so bypassing it and incrementing counter"
  item = JSON.parse(cache_item)
  item["processed_counter"]+=1 if item["processed_counter"]
  @iron_cache_client.items.put(CGI::escape(url), item.to_json)
end


#initializing IW an Iron Cache
@iron_cache_client = IronCache::Client.new({"token" => params['iw_token'], "project_id" => params['iw_project_id']})
@iron_mq_client = IronMQ::Client.new(:token => params['iw_token'], :project_id => params['iw_project_id'])

#getting list of urls
messages = get_list_of_messages

#processing each url
messages.each do |message|
  url = CGI::unescape(message.body)
  #getting page details if page already processed
  cache_item = @iron_cache_client.items.get(CGI::escape(url))
  if cache_item
    process_page(url)
  else
    increment_counter(url, cache_item)
  end
  message.delete
end
