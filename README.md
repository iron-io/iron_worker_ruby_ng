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

code = IronWorkerNG::Code::Ruby.new
code.merge_worker 'path/to/my_worker.rb'
code.merge_gem 'activerecord'

# you can use hash_string to check if you need to reupload code
# note that hash_string check is fast while code upload can take a while (depends on how much things you merged)
puts code.hash_string

client.codes.create(code)

client.tasks.create('MyWorker', 'foo' => 'bar')
```
