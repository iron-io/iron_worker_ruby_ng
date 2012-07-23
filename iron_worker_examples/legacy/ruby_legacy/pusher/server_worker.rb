require 'iron_worker'
require 'json'

class ServerWorker < IronWorker::Base

  attr_accessor :worker_ids, :api_key, :api_secret, :app_id

  merge_gem 'signature'
  merge_gem 'pusher'

  def run()
    log "#{@app_id}--#{@api_key}"
    Pusher.app_id = @app_id
    Pusher.key = @api_key
    Pusher.secret = @api_secret
    # Pusher.logger.level = Logger::DEBUG
    Pusher.encrypted = true

    @worker_ids.each do |w|
      log "Sending command to terminate worker #{w}..."
      #sending message via pusher
      Pusher['commands_channel'].trigger!('close', {:id=>w})
    end
  end
end