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

# Creating A Worker

Each IronWorkerNG Ruby worker is just Ruby code. It can be as simple or as complex as you want. For example,
the following is an acceptable worker:

```ruby
puts "Hello Worker!"
puts "My task_id is #{@iron_task_id}"
puts "I got '#{params}' parameters"
```

All output to `STDOUT` will be logged and available for your review when your worker finishes execution.

# Creating The Code Package

Before you can run use IronWorker, be sure you've [created a free account with Iron.io](http://www.iron.io)
and [setup your Iron.io credentials on your system](http://dev.iron.io/articles/configuration/) (either in a json
file or using ENV variables). You only need to do that once for your machine. If you've done that, then you can continue.

Since our worker will be executed in the cloud, you'll need to bundle all the necessary gems,
supplementary data, and other dependencies with it. `.worker` files make it easy to define your worker.

```ruby
# define the runtime language, this can be ruby, java, node, php, go, etc.
runtime "ruby"
# exec is the file that will be executed:
exec "hello_worker.rb"
```

You can read more about `.worker` files here: http://dev.iron.io/worker/reference/dotworker/

## Uploading the Code Package

If your .worker file is called `hello.worker`, then run:

    iron_worker upload hello

This will upload your worker with the name "hello" so you can reference it like that when queuing up tasks for it.

## Queue Up a Task for your Worker

You can quicky queue up a task for your worker from the command line using:

    iron_worker queue hello

Use the `-p` parameter to pass in a payload:

    iron_worker queue hello -p "{\"hi\": \"world\"}"

Most commonly you'll be queuing up tasks from code though, so you can do this:

```ruby
require "iron_worker_ng"
client = IronWorkerNG::Client.new
100.times do
   client.tasks.create("hello", "foo"=>"bar")
end
```

## Retry a Task

You can retry task by id using same payload and options:

    iron_worker retry 5032f7360a4681382838e082

or
```ruby
client.tasks.retry('5032f7360a4681382838e082', :delay => 10)
```


### Debugging

To get a bunch of extra output to debug things, turn it on using:

    IronCore::Logger.logger.level = ::Logger::DEBUG


## IronWorkerNG::Code::Base API

The IronWorkerNG::Code::Base class will help you package your code for upload, but to upload it to the cloud, you'll need to use the `IronWorkerNG::Client` class.

### initialize(*args)

Create new code package with the specified args.

```ruby
code_from_workerfile = IronWorkerNG::Code::Base.new(:workerfile => 'example.worker')
code_with_name = IronWorkerNG::Code::Base.new(:exec => 'example.rb', :name => 'Example')
code_with_guessed_name = IronWorkerNG::Code::Base.new(:exec => 'example.rb')
code = IronWorkerNG::Code::Base.new
```

### runtime()

Return the code package's runtime.

```ruby
puts code.runtime
```

### runtime=(runtime)

Sets the code package's runtime. If no runtime provided it defaults to 'ruby'.

```ruby
code.runtime = 'ruby'
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

### remote_build_command(cmd)
### build(cmd)

Command which will be executed once (on worker upload). Can be used for heavy tasks like building your worker from sources. Check https://github.com/iron-io/iron_worker_examples/tree/master/binary/phantomjs for real world example.

```ruby
code.remote_build_command('curl http://www.kernel.org/pub/linux/kernel/v3.0/linux-3.4.6.tar.bz2 -o linux-3.4.6.tar.bz2 && tar xf linux-3.4.6.tar.bz2')
```

### full_remote_build(activate)

If set to true, activates full remote build mode. In this mode iron_worker will try to resolve as much things as possible at build step. For example, all gems will be installed at build step, which will allow you to use gems with native extensions.

### remote

Alias for `full_remote_build(true)`.

### run()

Runs code package on your local box. Can be useful for testing.

```ruby
code.run
```

### merge_file(path, dest = '')
### file(path, dest = '')

Merge the file located at `path` into the code package. If `dest` is set, it will be used as the path to a directory within the zip, into which the file will be merged. If the directory does not exist, it will be automatically created.

```ruby
code.merge_file '../config/database.yml' # will be in the same directory as worker
code.merge_file 'clients.csv', 'information/clients' # will be in information/clients subdirectory
```

### merge_dir(path, dest = '')
### dir(path, dest = '')

Recursively merge the directory located at path into the code package. If `dest` is set, it will be used as the path to a directory within the zip, into which the directory specified by `path` will be merged. If `dest` is set but does not exist, it will be automatically created.

```ruby
code.merge_dir '../config' # will be in the same directory as worker
code.merge_dir 'lib', 'utils' # will be in utils subdirectory, accessible as utils/lib
```

### merge_deb(path)
### deb(path)

Merges provided deb package into your worker. Please note that it should be x86-64 deb and we don't do any dependencies resolving. It might not work for some packages which expects to find things it predefined place (e.g. imagemagick looks for codecs in /usr/lib/ImageMagick-X.X.X/codecs). If you are uploading from non-debian OS, just use full remote build, so deb manipulations will be done on IronWorker servers. Following example brings power of [pdftk](http://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/) to your worker.

```ruby
code.merge_deb 'http://mirror.pnl.gov/ubuntu/pool/universe/p/pdftk/pdftk_1.44-3_amd64.deb'
code.merge_deb 'http://mirror.pnl.gov/ubuntu/pool/main/g/gcj-4.6/libgcj12_4.6.1-4ubuntu2_amd64.deb'
```

## IronWorkerNG::Code::Ruby API

Specific methods for ruby runtime.

### merge_exec(path, klass = nil)
### exec(path, klass = nil)

Merge the exec located at `path`. If `klass` is provided, it'll try to instantiate it, set attrs from params and fire up `run` method when executed.

```ruby
code.merge_exec 'my_worker.rb'
```

### merge_gem(name, version = '>= 0')
### gem(name, version = '>= 0')

Merge a gem with dependencies. Gems with native extensions will not be merged by default, switching to full remote build should fix this. You can use version constrains if you need a specific gem version. Please note that `git` and `path` gems aren't supported yet.

```ruby
code.merge_gem 'activerecord'
code.merge_gem 'paperclip', '< 3.0.0,>= 2.1.0'
```

### merge_gemfile(path, *groups)
### gemfile(path, *groups)

Merge all gems from specified the groups in a Gemfile. Please note that this will not auto-require the gems when executing the worker.

```ruby
code.merge_gemfile '../Gemfile', 'common', 'worker' # merges gems from common and worker groups
```

## IronWorkerNG::Code::Binary API

Specific methods for binary (freeform) runtime.

### merge_exec(path)
### exec(path)

Merge the exec located at `path`. 

```ruby
code.merge_exec 'my_worker.sh'
```

## IronWorkerNG::Code::Go API

Specific methods for go runtime. It'll run provided exec via 'go run'.

### merge_exec(path)
### exec(path)

Merge the exec located at `path`. 

```ruby
code.merge_exec 'my_worker.go'
```

## IronWorkerNG::Code::Java API

Specific methods for java runtime.

### merge_exec(path, klass = nil)
### exec(path, klass = nil)

Merge the exec located at `path`. If class isn't provided, it'll relay on jar's manifest.

```ruby
code.merge_exec 'my_worker.jar'
```

### merge_jar(path)
### jar(path)

Merge the jar located at `path`. It'll be added to classpath when executing your worker.

```ruby
code.merge_jar 'xerces.jar'
```

## IronWorkerNG::Code::Mono API

Specific methods for mono (.net) runtime.

### merge_exec(path)
### exec(path)

Merge the exec located at `path`. 

```ruby
code.merge_exec 'my_worker.exe'
```

## IronWorkerNG::Code::Node API

Specific methods for node runtime.

### merge_exec(path)
### exec(path)

Merge the exec located at `path`. 

```ruby
code.merge_exec 'my_worker.js'
```

## IronWorkerNG::Code::Perl API

Specific methods for perl runtime.

### merge_exec(path)
### exec(path)

Merge the exec located at `path`. 

```ruby
code.merge_exec 'my_worker.pl'
```

## IronWorkerNG::Code::PHP API

Specific methods for PHP runtime.

### merge_exec(path)
### exec(path)

Merge the exec located at `path`. 

```ruby
code.merge_exec 'my_worker.php'
```

## IronWorkerNG::Code::Python API

Specific methods for python runtime.

### merge_exec(path)
### exec(path)

Merge the exec located at `path`. 

```ruby
code.merge_exec 'my_worker.py'
```

### merge_pip(name, version = '')
### pip(name, version = '')

Merge a pip package with dependencies. If any pip package contains native extensions, switch to full remote build. You can use version constrains if you need a specific pip package version.

```ruby
code.merge_pip 'iron_mq'
code.merge_pip 'iron_worker', '==0.2'
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
