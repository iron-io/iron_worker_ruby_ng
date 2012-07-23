# WebCrawler Worker

This is an example of web crawler that just get all links on given site and follow them (recursively queue new workers if possible) to find new links and so on with limited deep and only on given domain.

## Getting Started

###Configure crawler
- url = 'http://sample.com' # url to domain you want to crawl
- page_limit = 1000 #maximum number of links to collect
- depth = 3 #maximum deep level
- max_workers = 2 #max number of concurrent workers to use - workers are fully recursive if this possible worker queue another worker
- redis_connection = config_data['redis_uri'] # shared redis db to store found links and current number of workers

### Start crawler
- ruby run_crawler.rb