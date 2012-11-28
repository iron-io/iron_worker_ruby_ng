require 'iron_worker_ng'

client = IronWorkerNG::Client.new(:token => params['token'], :project_id => params['project_id'])

puts "Queueing slave workers..."
slaves = params['slaves']
slaves.keys.each do |slave|
  puts "Queueing #{slave} with params #{slaves[slave].inspect}"
  client.tasks.create('slave', slaves[slave])
end
puts 'Done'
