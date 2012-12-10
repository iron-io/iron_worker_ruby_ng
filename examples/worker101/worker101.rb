require 'twitter'
require 'json'

config = JSON.parse(params['config'], symbolize_names: true)
twitter = Twitter::Client.new(config)

puts "Starting Ruby Worker101 at #{Time.now}."
puts "We got following params #{params}."
puts "Searching Twitter for #{params['query']}..."
twitter.search(params['query']).results.each do |status|
  puts status.full_text
end
puts "Worker101 completed at #{Time.now}."

