# Basic Usage

Visit http://iron.io for more details.

## Create Worker

Worker's class name must match file name (e.g MyWorker class in my_worker.rb).

```ruby
require 'active_record'

class MyWorker
  def run
    # params hash is available here
    # do something fun
  end
end
```

## Create Runner

```ruby
require 'iron_worker_ng'

client = IronWorkerNG::Client.new('PROJECT_ID', 'TOKEN')

package = IronWorkerNG::RubyPackage.new('path/to/my_worker.rb') # package name will be set to worker's class name
package.merge_gem 'activerecord'

# you can use hash_string to check if you need to reupload package
# note that hash_string check is fast while package upload can take a while (depends on how much things you merged)
puts package.hash_string

client.upload(package)

client.queue('MyWorker', 'foo' => 'bar')
```
