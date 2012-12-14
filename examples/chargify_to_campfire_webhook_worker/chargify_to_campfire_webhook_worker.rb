require 'cgi'
require 'broach'

# the payload we get from github needs to be decoded first
cgi_parsed = CGI::parse(payload)
puts "cgi_parsed: #{cgi_parsed.inspect}"

event = cgi_parsed["event"][0]

# parse campfire config
cfg = JSON.parse(File.read('campfire_config.json'))
puts "campfire config: #{cfg.inspect}"

Broach.settings = {
  'account' => cfg['account'],
  'token'   => cfg['token'],
  'use_ssl' => true
}
Broach.speak(cfg['room'], event)

puts 'Done'
