require 'iron_worker'

class TwitterWorker < IronWorker::Base
 
  attr_accessor :twitter_config, :message

  merge_gem "twitter"

  def run
    log "job started"
    configure_twitter
    log "updating with #{@message}"
    Twitter.update "#{@message} at #{Time.now.strftime('%l:%M%P')}"
    log "Job finished!"
  end

  def configure_twitter
    log "Initializing twitter..."
    Twitter.configure do |x|
      x.consumer_key       = @twitter_config['consumer_key']
      x.consumer_secret    = @twitter_config['consumer_secret']
      x.oauth_token        = @twitter_config['oauth_token']
      x.oauth_token_secret = @twitter_config['oauth_token_secret']
    end

    log "Twitter config done!"
  end
end
