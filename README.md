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

package = IronWorkerNG::Package.new('MyWorkerPackage') # defaults to first merged worker
package.merge_gem 'activerecord'
package.merge_worker 'my_worker.rb', 'MyWorker' # if worker name is omited, it'll be guessed from file name

# you can use hash_string to check if you need to reupload package
# note that hash_string check is fast, while package upload can take a while (depends on how much things you merged)
puts package.hash_string

client.upload(package)

client.queue('MyWorkerPackage', 'MyWorker') # if no worker name specified, first merged worker will be used
```
