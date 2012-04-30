require 'iron_worker_ng'

# token and project id are available inside worker
client = IronWorkerNG::Client.new(:token => params[:token],
                                  :project_id => params[:project_id])

puts 'Running slave workers...'
task_ids = []
params[:args].each do |arg|
  puts "Queueing slave with arg=#{arg.to_s}"
  task_ids << client.tasks.create('SlaveWorker', { :arg => arg }).id
end

puts 'Retriving results from slaves logs'
results = task_ids.map do |id|
  client.tasks.wait_for(id)
  client.tasks.log(id).to_i
end

puts "Sum = #{ results.inject(:+) }"

puts 'Done'
