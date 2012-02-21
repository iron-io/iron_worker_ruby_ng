# Basic Usage

Visit http://iron.io for more details.

## Create Worker

You can just put any code into worker or can create class with name matching file name (e.g MyWorker class in my_worker.rb) and run method.

```ruby
require 'active_record'

# @params hash is available here
# do something fun
```

## Create Runner

```ruby
require 'iron_worker_ng'

client = IronWorkerNG::Client.new('IRON_IO_PROJECT_ID', 'IRON_IO_TOKEN')

package = IronWorkerNG::Package::Ruby.new
package.merge_worker 'path/to/my_worker.rb'
package.merge_gem 'activerecord'

# you can use hash_string to check if you need to reupload package
# note that hash_string check is fast while package upload can take a while (depends on how much things you merged)
puts package.hash_string

client.upload(package)

client.queue('MyWorker', 'foo' => 'bar')
```
