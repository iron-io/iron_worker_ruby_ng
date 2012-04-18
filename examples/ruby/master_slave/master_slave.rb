require 'iron_worker_ng'

# to run examples, you must specify iron.io authentication token and project id
token, project_id = [ ENV['IRON_IO_TOKEN'], ENV['IRON_IO_PROJECT_ID'] ]
raise("please set $IRON_IO_TOKEN and $IRON_IO_PROJECT_ID " +
      "environment variables") unless token and project_id

# initializing api object with them
client = IronWorkerNG::Client.new(:token => token,
                                  :project_id => project_id)

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
