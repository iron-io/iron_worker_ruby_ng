require 'iron_worker_ng'

# initializing client object
client = IronWorkerNG::Client.new

# create master code bundle
master = IronWorkerNG::Code::Ruby.new
master.merge_exec(File.dirname(__FILE__) + '/master_worker.rb')
master.merge_gem('iron_worker_ng') # we need it to queue slave workers

# create slave code bundle
slave = IronWorkerNG::Code::Ruby.new
slave.merge_exec(File.dirname(__FILE__) + '/slave_worker.rb')

# upload both
client.codes.create(master)
client.codes.create(slave)

# run master task
task_id = client.tasks.create('MasterWorker',
                              { 
                                :args => [ [1, 2, 3],
                                           [4, 5, 6],
                                           [7, 8, 9] ]
                              }).id

# wait for the task to finish
client.tasks.wait_for(task_id)

# retriving task log
log = client.tasks.log(task_id)

#> log.lines.find{ |l| l =~ /Sum =/ } == "Sum = 45\n" -- correct result in log
