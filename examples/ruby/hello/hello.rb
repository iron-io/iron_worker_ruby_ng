require 'iron_worker_ng'

# initializing client object
client = IronWorkerNG::Client.new

# create ruby code bundle
code = IronWorkerNG::Code.new do
  runtime 'ruby'
  exec(File.dirname(__FILE__) + '/hello_worker.rb')
end

# upload it to iron.io
client.codes.create(code)

# create task to run the bundle
task_id = client.tasks.create('HelloWorker').id

# wait for the task to finish
client.tasks.wait_for(task_id)

# retriving task log
log = client.tasks.log(task_id) #> log == "hello\n" -- worker stdout is in log 
