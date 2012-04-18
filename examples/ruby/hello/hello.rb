require 'iron_worker_ng'

# to run examples, you must specify iron.io authentication token and project id
token, project_id = [ ENV['IRON_IO_TOKEN'], ENV['IRON_IO_PROJECT_ID'] ]
raise("please set $IRON_IO_TOKEN and $IRON_IO_PROJECT_ID " +
      "environment variables") unless token and project_id

# initializing api object with them
client = IronWorkerNG::Client.new(:token => token,
                                  :project_id => project_id)

# create ruby code bundle
code = IronWorkerNG::Code::Ruby.new
code.merge_exec(File.dirname(__FILE__) + '/hello_worker.rb')

# upload it to iron.io
client.codes.create(code)

# create task to run the bundle
task_id = client.tasks.create('HelloWorker').id

# wait for the task to finish
client.tasks.wait_for(task_id)

# retriving task log
log = client.tasks.log(task_id) #> log == "hello\n" -- worker stdout is in log 
