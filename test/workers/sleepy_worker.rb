require 'stathat'

sleep_i = @params['sleep'] || 60
puts "worker #{@params['i']}"
puts "Going to sleep at #{Time.now} for #{sleep_i}..."
puts "posting 1 to stathat"
StatHat::API.ez_post_count("Max Concurrency Test", @params['stathat']['email'], 1)
sleep sleep_i
puts "Woke up at #{Time.now}"

