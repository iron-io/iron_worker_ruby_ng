# Basic Usage

Visit http://iron.io for more details.

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

package = IronWorkerNG::Package.new
package.merge_gem 'activerecord'
package.merge_worker 'my_worker.rb', 'MyWorker'

puts package.hash_string # you can use it to check if reupload needed

client.upload(package)

client.queue('MyWorker')
```
