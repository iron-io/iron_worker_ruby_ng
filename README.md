# Introduction

To run your code in cloud you need to do three things:

- **Create code package**
- **Upload code package**
- **Queue or schedule tasks** for execution 

While you can use [REST APIs](http://dev.iron.io/worker/reference/api) for that, it's easier to use an 
IronWorker library created specifically for your language of choice, such as this gem, IronWorkerNG.

# Preparing Your Environment

You'll need to register at http://iron.io/ and get your credentials to use IronWorkerNG. Each account can have an unlimited number of projects, so take advantage of it by creating separate projects for development, testing and production. Each project is identified by a unique project ID and requires your access token before it will perform any action, like uploading or queuing workers.

Also, you'll need a Ruby 1.9 interpreter and the IronWorkerNG gem. Install it using following command.

```sh
gem install iron_worker_ng
```

We recommend that you install the `typhoeus` gem as well for faster API interaction.

```sh
gem install typhoeus
```

# Creating A Worker

Each IronWorkerNG Ruby worker is just Ruby code. It can be as simple or as complex as you want. For example, the following is an acceptable worker:

```ruby
puts "I'm worker"
puts "My task_id is #{@iron_worker_task_id}"
puts "I'm executing inside #{@iron_io_project_id} and was queued using #{@iron_io_token} token"
puts "I got '#{params}' parameters"
```

All output to `STDOUT` will be logged and available for your review when your worker finishes execution.

# Creating The Code Package

Because your worker will be executed in the cloud, you'll need to bundle all the necessary gems, supplementary data, and other dependencies with it. `IronWorkerNG::Code::Ruby` makes this easy.

```ruby
code = IronWorkerNG::Code::Ruby.new

code.merge_exec 'my_worker.rb'
code.merge_file '../lib/utils.rb'
code.merge_dir '../config'
code.merge_gem 'activerecord'
```

## IronWorkerNG::Code::Ruby API

The IronWorkerNG::Code::Ruby class will help you package your code for upload, but to upload it to the cloud, you'll need to use the `IronWorkerNG::Client` class.

### initialize(*args)

Create new code package with the specified args.

```ruby
code_with_name = IronWorkerNG::Code::Ruby.new(:exec => 'cool_worker.rb', :name => 'CoolWorker')
code_with_guessed_name = IronWorkerNG::Code::Ruby.new(:exec => 'cool_worker.rb')
code_with_short_form_syntax = IronWorkeNG::Code::Ruby.new('cool_worker.rb')
code = IronWorkerNG::Code::Ruby.new # will need to use code.merge_exec later
```

### name()

Return the code package's name.

```ruby
puts code.name
```

### name=(name)

Sets the code package's name.

```ruby
code.name = 'CoolWorker'
```

### hash_string()

Return the hash string for the code package. If you want to prevent uploading unchanged code packages, you can use it to check if any changes were made. It's very efficient, so it shouldn't cause any performance impact.

```
puts code.hash_string
```

### merge_file(path, dest = '')

Merge the file located at `path` into the code package. If `dest` is set, it will be used as the path to a directory within the zip, into which the file will be merged. If the directory does not exist, it will be automatically created.

```ruby
code.merge_file '../config/database.yml' # will be in the same directory as worker
code.merge_file 'clients.csv', 'information/clients' # will be in information/clients subdirectory
```

### merge_dir(path, dest = '')

Recursively merge the directory located at path into the code package. If `dest` is set, it will be used as the path to a directory within the zip, into which the directory specified by `path` will be merged. If `dest` is set but does not exist, it will be automatically created.

```ruby
code.merge_dir '../config' # will be in the same directory as worker
code.merge_dir 'lib', 'utils' # will be in utils subdirectory, accessible as utils/lib
```

### merge_exec(path, name = nil)

Merge the worker located at `path`. If `name` is omitted, a camel-cased version of the file name will be used. **You can have only one worker merged per code package.**

```ruby
code.merge_exec 'my_worker.rb' # name will be MyWorker
```

### merge_gem(name, version = '>= 0')

Merge a gem with dependencies. Please note that gems which contains binary extensions will not be merged for now, as binary extensions are not supported at this time; we have [a set](http://dev.iron.io/worker/reference/environment/?lang=ruby#ruby_gems_installed) of the most common gems with binary extensions preinstalled for your use. You can use version constrains if you need a specific gem version.

```ruby
code.merge_gem 'activerecord'
code.merge_gem 'paperclip', '< 3.0.0,>= 2.1.0'
```

### merge_gemfile(path, *groups)

Merge all gems from specified the groups in a Gemfile. Please note that this will not auto-require the gems when executing the worker.

```ruby
code.merge_gemfile '../Gemfile', 'common', 'worker' # merges gems from common and worker groups
```

# Upload Your Worker

When you have your code package, you are ready to upload and run it on the IronWorker cloud. 

```ruby
# Initialize the client
client = IronWorkerNG::Client.new(:token => 'IRON_IO_TOKEN', :project_id => 'IRON_IO_PROJECT_ID')
# Upload the code
client.codes.create(code)
```

**NOTE**: You only need to call `client.codes.create(code)` once for each time your code changes.

# Queue Up Tasks for Your Worker

Now that the code is uploaded, we can create/queue up tasks. You can call this over and over 
for as many tasks as you want. 

```ruby
client.tasks.create('MyWorker', {:client => 'Joe'})
```

# The Rest of the IronWorker API

## IronWorker::Client

You can use the `IronWorkerNG::Client` class to upload code packages, queue tasks, create schedules, and more.

### initialize(options = {})

Create a client object used for all your interactions with the IronWorker cloud.

```ruby
client = IronWorkerNG::Client.new(:token => 'IRON_IO_TOKEN', :project_id => 'IRON_IO_PROJECT_ID')
```

### codes.list(options = {})

Return an array of information about uploaded code packages. Visit http://dev.iron.io/worker/reference/api/#list_code_packages for more information about the available options and the code package object format.

```ruby
client.codes.list.each do |code|
  puts code.inspect
end
```

### codes.get(code_id)

Return information about an uploaded code package with the specified ID. Visit http://dev.iron.io/worker/reference/api/#get_info_about_a_code_package for more information about the code package object format.

```ruby
puts client.codes.get('1234567890').name
```

### codes.create(code)

Upload an `IronWorkerNG::Code::Ruby` object to the IronWorker cloud.

```ruby
client.codes.create(code)
```

### codes.delete(code_id)

Delete the code package specified by `code_id` from the IronWorker cloud.

```ruby
client.codes.delete('1234567890')
```

### codes.revisions(code_id, options = {})

Get an array of revision information for the code package specified by `code_id`. Visit http://dev.iron.io/worker/reference/api/#list_code_package_revisions for more information about the available options and the revision objects.

```ruby
client.codes.revisions('1234567890').each do |revision|
  puts revision.inspect
end
```

### codes.download(code_id, options = {})

Download the code package specified by `code_id` and return it as an array of bytes. Visit http://dev.iron.io/worker/reference/api/#download_a_code_package for more information about the available options.

```ruby
data = client.codes.download('1234567890')
```

### tasks.list(options = {})

Retrieve an array of information about your workers' tasks. Visit http://dev.iron.io/worker/reference/api/#list_tasks for more information about the available options and the task object format.

```ruby
client.tasks.list.each do |task|
  puts task.inspect
end
```

### tasks.get(task_id)

Return information about the task specified by `task_id`. Visit http://dev.iron.io/worker/reference/api/#get_info_about_a_task for more information about the task object format.

```ruby
puts client.tasks.get('1234567890').code_name
```

### tasks.create(code_name, params = {}, options = {})

Queue a new task for the code package specified by `code_name`, passing the `params` hash to it as a payload and returning a task object with only the `id` field filled. Visit http://dev.iron.io/worker/reference/api/#queue_a_task for more information about the available options.

```ruby
task = client.tasks.create('MyWorker', {:client => 'Joe'}, {:delay => 180})
puts task.id
```

### tasks.cancel(task_id)

Cancel the task specified by `task_id`.

```ruby
client.tasks.cancel('1234567890')
```

### tasks.cancel_all(code_id)

Cancel all tasks for the code package specified by `code_id`.

```ruby
client.tasks.cancel_all('1234567890')
```

### tasks.log(task_id)

Retrieve the full task log for the task specified by `task_id`. Please note that log is available only after the task has completed execution. The log will include any output to `STDOUT`.

```ruby
puts client.tasks.log('1234567890')
```

### tasks.set_progress(task_id, options = {})

Set the progress information for the task specified by `task_id`. This should be used from within workers to inform you about worker execution status, which you can retrieve with a `tasks.get` call. Visit http://dev.iron.io/worker/reference/api/#set_a_tasks_progress for more information about the available options.

```ruby
client.tasks.set_progress('1234567890', {:msg => 'Still running...'})
```

### tasks.wait_for(task_id, options = {})

Wait (block) while the task specified by `task_id` executes. Options can contain a `:sleep` parameter used to modify the delay between API invocations; the default is 5 seconds. If a block is provided (as in the example below), it will be called after each API call with the task object as parameter.

```ruby
client.tasks.wait_for('1234567890') do |task|
  puts task.msg
end
```

### schedules.list(options = {})

Return an array of scheduled tasks. Visit http://dev.iron.io/worker/reference/api/#list_scheduled_tasks for more information about the available options and the scheduled task object format.

```ruby
client.schedules.list.each do |schedule|
  puts schedule.inspect
end
```

### schedules.get(schedule_id)

Return information about the scheduled task specified by `schedule_id`. Visit http://dev.iron.io/worker/reference/api/#get_info_about_a_scheduled_task for more information about the scheduled task object format.

```ruby
puts client.schedules.get('1234567890').last_run_time
```

### schedules.create(code_name, params = {}, options = {})

Create a new scheduled task for the code package specified by `code_name`, passing the params hash to it as a data payload and returning a scheduled task object with only the `id` field filled. Visit http://dev.iron.io/worker/reference/api/#schedule_a_task for more information about the available options.

```ruby
schedule = client.schedules.create('MyWorker', {:client => 'Joe'}, {:start_at => Time.now + 3600})
puts schedule.id
```

### schedules.cancel(schedule_id)

Cancel the scheduled task specified by `schedule_id`.

```ruby
client.schedules.cancel('1234567890')
```
