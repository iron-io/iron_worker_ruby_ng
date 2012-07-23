require 'iron_worker'
require 'yaml'

IronWorker.logger.level = Logger::DEBUG

require_relative "server_worker.rb"
require_relative "client_worker.rb"

config_data = YAML.load_file('../_config.yml')

IronWorker.configure do |config|
  config.token = config_data['iw']['token']
  config.project_id = config_data['iw']['project_id']
end

num_clients = 5
worker_ids = num_clients.times.map{ 0+Random.rand(999) }.sort 

#running clients
num_clients.times {|i|
  cw = ClientWorker.new
  cw.api_key = config_data["pusher"]["key"]
  cw.api_secret = config_data["pusher"]["secret"]
  cw.worker_id = worker_ids[i]

  cw.queue(:timeout=>60)

#wait until worker start
  loop do
    status= cw.status["status"]
    puts "Checking status- #{status}"
    break if ['running', 'error', 'timeout'].include?(status)
  end
}

# running killer
sw = ServerWorker.new
sw.api_key = config_data["pusher"]["key"]
sw.api_secret = config_data["pusher"]["secret"]
sw.app_id = config_data["pusher"]["app_id"]
sw.worker_ids = worker_ids
sw.queue

status = sw.wait_until_complete
puts "ServerWorker status: " + status.inspect
puts sw.get_log
