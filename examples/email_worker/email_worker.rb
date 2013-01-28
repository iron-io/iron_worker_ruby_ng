require 'mail'
require 'rest'
require 'iron_cache'

# 'params' name is used in Mail widely
pars = JSON.parse(payload, symbolize_names: true)

# Configure smtp settings to send email.
Mail.defaults do
  delivery_method :smtp, pars[:smtp]
end

[pars[:to]].flatten.each do |to|
  msg = Mail.new do
    to to
    from pars[:from]
    subject pars[:subject]
    body pars[:body]
  end
  details = msg.deliver

  puts "email:#{to}, details:#{details.to_s}"

  if pars[:endpoint]
    # here is the example how you could send email details from this worker to your api
    puts "initializing client"
    web_client = Rest::Client.new
    puts "sending api request"
    web_client.get(pars[:endpoint], email: to, details: details.to_s)
  end

  # or put email details in iron_cache
  if pars[:iron]
    puts "initializing cache"
    cache = IronCache::Client.new(pars[:iron])
    puts "sending message details to cache"
    cache.items.put(to, details.to_s)
  end
end

puts "worker finished"
