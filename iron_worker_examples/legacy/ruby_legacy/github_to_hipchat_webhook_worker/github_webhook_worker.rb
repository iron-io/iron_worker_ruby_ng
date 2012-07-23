require 'iron_worker'
require 'cgi'
require 'yaml'

# bump....
class GithubWebhookWorker < IronWorker::Base

  merge 'webhook_config.yml'
  merge_gem 'hipchat-api'

  def run

    puts "hello webhook!  payload: #{IronWorker.payload}"

    payload = IronWorker.payload #["payload=".length, IronWorker.payload.length]

    cgi_parsed = CGI::parse(payload)
    puts "cgi_parsed: " + cgi_parsed.inspect

    parsed = JSON.parse(cgi_parsed["payload"][0])
    puts "parsed: " + parsed.inspect

    webhook_config = YAML.load_file('webhook_config.yml')
    puts 'webhook_config=' + webhook_config.inspect

    hipchat = HipChat::API.new(webhook_config['hipchat']['api_key'])

    parsed["commits"].each do |c|
      puts hipchat.rooms_message(webhook_config['hipchat']['room'], 'WebhookWorker', "Rev: <a href=\"#{c["url"]}\">#{c["id"][0,9]}</a> - #{c["message"]}", true).body
    end

  end

end
