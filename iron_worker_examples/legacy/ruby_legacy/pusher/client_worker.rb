require 'iron_worker'
require 'json'

class ClientWorker < IronWorker::Base

  attr_accessor :worker_id, :api_key, :api_secret

  merge_gem 'libwebsocket'
  merge_gem 'pusher-client'

  def run()
    puts "I am worker #{worker_id}"
    options = {:secret => @api_secret}
    #options[:encrypted] = true
    socket = PusherClient::Socket.new(@api_key, options)

    #connect in async way
    socket.connect(true)
    socket.subscribe('commands_channel')
    @exit = false

    #subscribing to close message
    socket['commands_channel'].bind('close') do |data|
      data = JSON.parse(data)
      puts "worker #{data["id"]} should be terminated"
      unless @exit
        @exit = data["id"] == @worker_id
      end
    end

    #never ending loop
    loop do
      sleep(1)
      log "doing hard work"
      if @exit
        log "Hey i'm terminating, server told me to."
        break
      end
    end
  end
end