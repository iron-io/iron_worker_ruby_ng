# Basic Usage

Visit http://iron.io for more details.

## Create Worker

You can just put any code into worker or can create class with name matching file name (e.g MyWorker class in my_worker.rb) and run method.

```ruby
require 'active_record' # just in case

# do something fun
puts params[:foo]
```

## Create Runner

```ruby
require 'iron_worker_ng'

client = IronWorkerNG::Client.new('IRON_IO_TOKEN', 'IRON_IO_PROJECT_ID')

code = IronWorkerNG::Code::Ruby.new
code.merge_worker 'path/to/my_worker.rb'
code.merge_gem 'activerecord' # we are using it in our worker

# you can use hash_string to check if you need to reupload code
# note that hash_string check is fast while code upload can take a while (depends on how much things you merged)
puts code.hash_string

client.codes.create(code)

client.tasks.create('MyWorker', :foo => 'bar')
```

## CLI

Iron Worker NG got nice CLI tool bundled. Here is small example how to get your code running in cloud in few seconds.

```sh
% cat my_worker.rb
puts "my name is #{params[:name]} and it is #{params[:it]}"
% iron_worker_ng codes.create --ruby-merge-worker my_worker.rb
% TASK_ID=`iron_worker_ng tasks.create -n MyWorker -p name,worker -p it,fun --print-id`
% iron_worker_ng tasks.log -t $TASK_ID --live
my name is worker and it is fun
```
