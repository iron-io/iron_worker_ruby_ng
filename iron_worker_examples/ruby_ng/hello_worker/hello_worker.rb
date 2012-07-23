# worker code is common ruby code

puts "Starting Ruby HelloWorker at #{Time.now}"
puts "We got following params #{params}"
puts "Simulating hard work for 5 seconds..."
5.times do |i|
  puts "Sleep #{i}..."
  sleep 1
end
puts "HelloWorker completed at #{Time.now}"
