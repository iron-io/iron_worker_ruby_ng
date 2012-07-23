require 'iron_worker'
require 'cgi'
require 'yaml'

# bump......
class StathatWebhookWorker < IronWorker::Base

  merge 'webhook_config.yml'
  merge_gem 'stathat'

  def run

    puts "hello webhook!  payload: #{IronWorker.payload}"

    payload = IronWorker.payload #["payload=".length, IronWorker.payload.length]

    cgi_parsed = CGI::parse(payload)
    puts "cgi_parsed: " + cgi_parsed.inspect

    parsed = JSON.parse(cgi_parsed["payload"][0])
    puts "parsed: " + parsed.inspect

    webhook_config = YAML.load_file('webhook_config.yml')
    puts 'webhook_config=' + webhook_config.inspect

    error_count = parsed['events'].size
    puts "error_count=#{error_count}"
    p StatHat::API.ez_post_count(webhook_config['stathat']['stat_name'], webhook_config['stathat']['email'], error_count)

  end

end
