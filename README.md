# Introduction

To run your code in cloud you need to do two things - upload code package to be executed and queue or schedule it for execution. While you can use REST APIs for that, it's easier to use an IronWorker library created specifically for your language of choice, such as IronWorkerNG.

# Preparing Environment

You'll need to register at http://iron.io/ and get your credentials to use IronWorkerNG. Each account can have an unlimited number of projects, so take advantage of it by creating separate projects for development, testing and production. Each project is identified by a unique project_id and requires your access token to do any actions on it, like uploading or queuing workers.

Also, you'll need a Ruby 1.9 interpreter and the IronWorkerNG gem. Install it using following command.

```sh
gem install iron_worker_ng
```

We recommend that you install typhoeus gem as well for faster API interaction.

```sh
gem install typhoeus
```

# Creating Worker

IronWorkerNG Ruby worker is common Ruby code. It can be as simple as shown below or as complex as you want.

```ruby
puts "I'm worker"
puts "My task_id is #{@iron_worker_task_id}"
puts "I'm executing inside #{@iron_io_project_id} and was queued using #{@iron_io_token} token"
puts "I got '#{params}' parameters"
```

All output to stdout will be logged and available for your review when workers finish execution.

# Creating Code Package

As this code will be executed on the cloud, you'll need to supply it with all necessary gems and supplementary data. IronWorkerNG::Code::Ruby will help you to do this.

```ruby
code = IronWorkerNG::Code::Ruby.new

code.merge_worker 'my_worker.rb'
code.merge_file '../lib/utils.rb'
code.merge_dir '../config'
code.merge_gem 'activerecord'
```

## IronWorkerNG::Code::Ruby API

Please note that this API will help you to create code package but to upload it to IronWorker servers you'll need to use IronWorkerNG::Client API.

### initialize(name = nil)

Will create new code package with specified name. If name is omitted, camel-cased worker's file name will be used.

```ruby
code = IronWorkerNG::Code::Ruby.new
code_with_name = IronWorkerNG::Code::Ruby.new('CoolWorker')
```

### name()

Will return code package name.

```ruby
puts code.name
```

### hash_string()

```
puts code.hash_string
```

Will return code package hash string. If you want to prevent uploading unchanged code packages, you can use it to check if any changes were made. As it's very efficient, it shouldn't cause any performance impact.

### merge_file(path, dest = '')

```ruby
code.merge_file '../config/database.yml' # will be in the same directory as worker
code.merge_file 'clients.csv', 'information/clients' # will be in information/clients subdirectory
```

Merges file located at path into the code package. You can use the optional dest parameter to set destination directory which will be automatically created.

### merge_dir(path, dest = '')

Recursively merges the directory located at path into the code package. 

```ruby
code.merge_dir '../config' # will be in the same directory as worker
code.merge_dir 'lib', 'utils' # will be in utils subdirectory, accessible as utils/lib
```

### merge_worker(path, name = nil)

Merges worker located at path. If name is omitted, camel-cased file name will be used. You can have only one worker merged per code package.

```ruby
code.merge_worker 'my_worker.rb' # name will be MyWorker
```

### merge_gem(name, version = '>= 0')

Merges gem with dependencies. Please note that gems which contains binary extensions will not be merged at the moment, however we have sane set of such gems preinstalled at IronWorker servers. You can use version constrains if you need a specific gem version.

```ruby
code.merge_gem 'activerecord'
code.merge_gem 'paperclip', '< 3.0.0,>= 2.1.0'
```

### merge_gemfile(path, *groups)

Merges all gems from specified groups in Gemfile. Please note that it'll just merge gems and not auto require them when executing worker.

```ruby
code.merge_gemfile '../Gemfile', 'common', 'worker' # merges gems from common and worker groups
```

# Using IronWorker

When you have your code package you are ready to run it on IronWorker servers.

```ruby
client = IronWorkerNG::Client.new(:token => IRON_IO_TOKEN', :project_id => 'IRON_IO_PROJECT_ID')

client.codes.create(code)
client.tasks.create('MyWorker', {:client => 'Joe'})
```

## IronWorker::Client API

You can use IronWorkerNG::Client API to upload code packages, queue tasks, create schedules and more.

### initialize(options = {})

Creates client object used for all interactions with IronWorker servers.

```ruby
client = IronWorkerNG::Client.new(:token => 'IRON_IO_TOKEN', :project_id => 'IRON_IO_PROJECT_ID')
```

### codes.list(options = {})

Returns an array of information about uploaded codes. Visit http://dev.iron.io/worker/reference/api/#list_code_packages for more information about options and code information object format.

```ruby
client.codes.list.each do |code|
  puts code.inspect
end
```

### codes.get(code_id)

Returns information about uploaded code with specified code_id. Visit http://dev.iron.io/worker/reference/api/#get_info_about_a_code_package for more information about code information object format.

```ruby
puts client.codes.get('1234567890').name
```

### codes.create(code)

Uploads IronWorkerNG::Code::Ruby object to IronWorker servers.

```ruby
client.codes.create(code)
```

### codes.delete(code_id)

Deletes code with specified code_id from IronWorker servers.

```ruby
client.codes.delete('1234567890')
```

### codes.revisions(code_id, options = {})

Returns array of revision information for code package with specified code_id. Visit http://dev.iron.io/worker/reference/api/#list_code_package_revisions for more information about options and revision information object.

```ruby
client.codes.revisions('1234567890').each do |revision|
  puts revision.inspect
end
```

### codes.download(code_id, options = {})

Downloads the code package with specified id and returns it to you as array of bytes. Visit http://dev.iron.io/worker/reference/api/#download_a_code_package for more information about options.

```ruby
data = client.codes.download('1234567890')
```

### tasks.list(options = {})

Returns an array of information about tasks. Visit http://dev.iron.io/worker/reference/api/#list_tasks for more information about options and task information object format.

```ruby
client.tasks.list.each do |task|
  puts task.inspect
end
```

### tasks.get(task_id)

Returns information about task with specified task_id. Visit http://dev.iron.io/worker/reference/api/#get_info_about_a_task for more information about task information object format.

```ruby
puts client.tasks.get('1234567890').code_name
```

### tasks.create(code_name, params = {}, options = {})

Queues a new task for code with specified code_name, passes params hash to it and returns task information object with only id field filled. Visit http://dev.iron.io/worker/reference/api/#queue_a_task for more information about options.

```ruby
task = client.tasks.create('MyWorker', {:client => 'Joe'}, {:delay => 180})
puts task.id
```

### tasks.cancel(task_id)

Cancels the task with specified task_id.

```ruby
client.tasks.cancel('1234567890')
```

### tasks.cancel_all(code_id)

Cancels all tasks for code package identified by specified code_id.

```ruby
client.tasks.cancel_all('1234567890')
```

### tasks.log(task_id)

Returns full task log for task with specified task_id. Please note that log is available only when task completed execution.

```ruby
puts client.tasks.log('1234567890')
```

### tasks.set_progress(task_id, options = {})

Sets task progress information for task with specified task_id. This should be used from within workers to inform you about worker execution status which you'll get via a tasks.get call. Visit http://dev.iron.io/worker/reference/api/#set_a_tasks_progress for more information about options.

```ruby
client.tasks.set_progress('1234567890', {:msg => 'Still running...'})
```

### tasks.wait_for(task_id, options = {})

Waits while task identified by specified task_id executes. Options can contain :sleep parameter used to sleep between API invocations which defaults to 5 seconds. If block is provided, it'll be yielded after each API call with task information object as parameter.

```ruby
client.tasks.wait_for('1234567890') do |task|
  puts task.msg
end
```

### schedules.list(options = {})

Returns an array of information about schedules. Visit http://dev.iron.io/worker/reference/api/#list_scheduled_tasks for more information about options and schedule information object format.

```ruby
client.schedules.list.each do |schedule|
  puts schedule.inspect
end
```

### schedules.get(schedule_id)

Returns information about the schedule with specified schedule_id. Visit http://dev.iron.io/worker/reference/api/#get_info_about_a_scheduled_task for more information about schedule information object format.

```ruby
puts client.schedules.get('1234567890').last_run_time
```

### schedules.create(code_name, params = {}, options = {})

Creates a new schedule for code with specified code_name, passes params hash to it and returns schedule information object with only id field filled. Visit http://dev.iron.io/worker/reference/api/#schedule_a_task for more information about options.

```ruby
schedule = client.schedules.create('MyWorker', {:client => 'Joe'}, {:start_at => Time.now + 3600})
puts schedule.id
```

### schedules.cancel(schdule_id)

Cancels the schedule with specified schedule_id.

```ruby
client.schedules.cancel('1234567890')
```
