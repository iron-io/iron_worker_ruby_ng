# WebCrawler Nokogiri Worker

This is an example of web crawler based on Nokogiri, that just get all links on given site and follow them (recursively queue new workers if possible) to find new links and so on with limited deep and only on given domain.
After collecting links crawler put each link into iron_cache and in iron_mq to process it with PageProcessor.
Page processor make simple processing using Nokogiri parser - extracting all links,count number of images/css find largest image on page and calculate frequency of each word on page.
Additional page processing could be processed within a single worker or other workers could be used (to keep the workers
task specific).
To orchestrate this, you could fire up workers from the page processor or use multiple message queues in IronMQ and
have the workers run off of these queues.

## Getting Started

###Configure crawler
- url = 'http://sample.com' # url to domain you want to crawl
- page_limit = 1000 #maximum number of links to collect
- depth = 3 #maximum deep level
- max_workers = 2 #max number of concurrent workers to use - workers are fully recursive if this possible worker queue another worker
- iw_token = iron token
- iw_project_id = iron project id

### Start crawler/page processor
- upload crawler/page processor:  iron_worker upload web_crawler;iron_worker upload page_processor
- queue crawler: ruby run_crawler.rb