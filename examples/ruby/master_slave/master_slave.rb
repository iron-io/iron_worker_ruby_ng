require 'iron_worker_ng'

# initializing client object
client = IronWorkerNG::Client.new

root = File.dirname(__FILE__)

# create master code bundle
master = IronWorkerNG::Code::Ruby.new :workerfile => "#{root}/master.worker"

# create slave code bundle
slave = IronWorkerNG::Code::Ruby.new :workerfile => "#{root}/slave.worker"

# upload both
client.codes.create(master)
client.codes.create(slave)

# client.api.options is a hash containing iron.io *token*,
# *project_id* and other connection-related info
payload = client.api.options.merge(:args => [ [1, 2, 3],
                                              [4, 5, 6],
                                              [7, 8, 9] ])
# run master task
task_id = client.tasks.create('MasterWorker', payload).id

# wait for the task to finish
client.tasks.wait_for(task_id)

# retriving task log
log = client.tasks.log(task_id)

#> log.lines.find{ |l| l =~ /Sum =/ } == "Sum = 45\n" -- correct result in log
