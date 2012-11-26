require 'twitter'

puts "Starting Ruby Worker101 at #{Time.now}."
puts "We got following params #{params}."
puts "Searching Twitter for #{params['query']}..."
Twitter.search(params['query']).each do |status|
  puts status.full_text
end
puts "Worker101 completed at #{Time.now}."

