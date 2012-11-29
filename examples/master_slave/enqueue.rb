require 'iron_worker_ng'

client = IronWorkerNG::Client.new

slaves = {
  'slave one' => {'foo' => 'bar'},
  'slave two' => {'hello' => 'world'}
}

task_id = client.tasks_create('master', 'slaves' => slaves, 'token' => client.api.token, 'project_id' => client.api.project_id).id
puts "task id = #{task_id}"

client.tasks_wait_for(task_id)
log = client.tasks.log(task_id)
puts log
