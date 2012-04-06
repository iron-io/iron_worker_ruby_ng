require 'iron_worker_ng'

# token and project id are available inside worker
client = IronWorkerNG::Client.new(:token => iron_io_token,
                                  :project_id => iron_io_project_id)

log 'Running slave workers...'
task_ids = []
params[:args].each do |arg|
  log "Queueing slave with arg=#{arg.to_s}"
  task_ids << client.tasks.create('SlaveWorker', { :arg => arg }).id
end

log 'Retriving results from slaves logs'
results = task_ids.map do |id|
  client.tasks.wait_for(id)
  client.tasks.log(id).to_i
end

log "Sum = #{ results.inject(:+) }"

log 'Done'
