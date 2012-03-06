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

client = IronWorkerNG::Client.new('IRON_IO_TOKEN', 'IRON_IO_PROJECT_ID')

code = IronWorkerNG::Code::Ruby.new
code.merge_worker 'path/to/my_worker.rb'
code.merge_gem 'activerecord'

# you can use hash_string to check if you need to reupload code
# note that hash_string check is fast while code upload can take a while (depends on how much things you merged)
puts code.hash_string

client.codes.create(code)

client.tasks.create('MyWorker', 'foo' => 'bar')
```

## CLI

Iron Worker NG got nice CLI tool bundled. Here is small example how to get your code running in cloud in few seconds.

```sh
% cat my_worker.rb
puts "I got some params - #{@params.inspect}"
% iron_worker_ng codes.create --ruby-merge-worker my_worker.rb
% TASK_ID=`iron_worker_ng tasks.create -n MyWorker -p name,worker -p some,value --print-id`
% iron_worker_ng tasks.log -t $TASK_ID --live
I got some params - {"name"=>"worker", "some"=>"value"}
```
