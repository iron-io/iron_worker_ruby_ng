require 'iron_worker'

class TwilioSMSWorker < IronWorker::Base

  # Merge 'jwt' in because of twilio-ruby dependency.
  merge_gem 'jwt'
  merge_gem 'twilio-ruby'
  merge_gem 'rest-client'

  attr_accessor :sid, :token, :api_version,
                :from, :to, :message

  def run
    log "\nRunning TwilioSMSWorker...\n"

    log "\nConnecting to Twilio..."
    client = Twilio::REST::Client.new @sid, @token
    log "Connected."

    log "\nSending a text message..."
    client.account.sms.messages.create(
      :from => @from,
      :to => @to,
      :body => @message
    )
    log "Sent."
    
    log "\nFinished processing TwilioSMSWorker.\n\n"

  end
end
