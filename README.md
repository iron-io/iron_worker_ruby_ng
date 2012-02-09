# Basic Usage

## Create Worker

```ruby
require 'active_record'

class MyWorker
  def run
    # do something fun
  end
end
```

## Create Runner

```ruby
require 'iron_worker_ng'

client = IronWorkerNG::Client.new('PROJECT_ID', 'TOKEN')

client.upload do |code|
  code.merge_gem 'activerecord'
  code.merge_worker 'my_worker.rb', 'MyWorker'
end

client.queue('MyWorker')
```
