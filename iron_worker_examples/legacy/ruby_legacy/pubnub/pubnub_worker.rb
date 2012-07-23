require "iron_worker"

class PubNubWorker < IronWorker::Base

  # JSON gem is a dep of pubnub.rb
  merge_gem "json"
  merge "pubnub.rb"

  attr_accessor :secrets, :channel, :message

  def run
    # Setup PubNub, now i'm just showing off def's
    
    begin
      pub_nub = Pubnub.new(@secrets[:publish], @secrets[:subscribe], @secrets[:secret], true)
      log pub_nub.inspect
      pub_nub.publish({
        'channel' => @channel,
        'message' => @message
        })
      log "Message sent! :D"
    rescue => ex
      log "Exception: #{ex.message}"
      raise ex
    end     
  end
end
