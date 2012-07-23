require 'iron_worker'
require 'date'
require 'json'

class TwilioStatsWorker < IronWorker::Base

  #The unfinished procedures use 'twiliolib.rb'
  #merge File.join(File.dirname(__FILE__), "twiliolib.rb")
  merge_gem 'jwt'
  merge_gem 'twilio-ruby'
  merge_gem 'rest-client'

  #This could queue up workers to send out stats information.
  #merge_worker File.join(File.dirname(__FILE__), "gmail_worker.rb"), "GmailWorker"

  attr_accessor :sid, :token, :api_version

  def run
    log "\nRunning TwilioStatsWorker...\n"

    client = Twilio::REST::Client.new @sid, @token
    @account = client.account
    
    date_today = Time.now.utc.strftime('%Y-%m-%d')
    get_sms_messages_sent(date_today)

    #These calls need work
    #get_account_information
    #get_uncompleted_calls
    #get_volume_stats
      
    log "\nFinished processing TwilioStatsWorker.\n\n"
  end
    
  def get_sms_messages_sent(date)

    # print a list of sms messages (one http request)
    log "\nHere are the text messages sent on date (up to 10):"
    @account.sms.messages.list({:date_sent => date}).each do |sms|
      log sms.body
    end

    log "\nDoing the same but using the REST API:"
    resp = RestClient.get "https://#{@sid}:#{@token}@api.twilio.com/#{@api_version}/Accounts/#{@sid}/SMS/Messages.json"

    #log "Response code: %s" % [resp.code]
    #log "Response body: %s" % [resp.body] 

    result = JSON.parse(resp)      
    result["sms_messages"].each do |msg|
      log "#{msg["body"]}"
    end
    
    #send_mail(to, 'Daily report: SMS messages today', msg)
  end 
    
  def get_account_information
 
    log "\nListing account information:"
    resp = RestClient.get "https://#{@sid}:#{@token}@api.twilio.com/#{@api_version}/Accounts/#{@sid}"
 
    #log resp
 
    #result = JSON.parse(resp)      
    #msg = something
    #send_mail(to, 'Daily report: SMS messages today', msg)   
  end

  def get_uncompleted_calls(account)
    log "Starting get_uncompleted_calls"

    msg  = "Uncompleted Calls Report"
    
    resp = @account.request("/#{@api_version}/Accounts/#{@sid}/Calls.json", 'GET', {"StartTime" =>Time.now.strftime("%Y-%m-%d"), "Status"=>"failed"})
    resp.error! unless resp.kind_of? Net::HTTPSuccess
 
    json  = JSON.parse(resp.body)
    calls = json["calls"]
    msg+= ("\nFailed Calls list") if calls.size>0
    calls.each do |call|
      msg+= "\ncall - from #{call["from"]} - to #{call["to"]} ,status - #{call["status"]}, duration #{call["duration"]} " + ''
    end
    msg += "\nTotal failed calls :#{json["total"]}"

    log msg.inspect

    log "Finished with get_uncompleted_calls"
  end

  def get_volume_stats(account)
    log "Starting get_volume_stats"

    msg  = "Get Volume Stats Report"

    resp = account.request("/#{@api_version}/Accounts/#{@sid}/Calls.json", 'GET', {"StartTime" =>Time.now.strftime("%Y-%m-%d")})
    resp.error! unless resp.kind_of? Net::HTTPSuccess
    json = JSON.parse(resp.body)
    msg  += "\nTotal calls :#{json["total"]}"

    resp = account.request("/#{@api_version}/Accounts/#{@sid}/SMS/Messages.json", 'GET', {"DateSent" =>Time.now.strftime("%Y-%m-%d")})
    resp.error! unless resp.kind_of? Net::HTTPSuccess
    json = JSON.parse(resp.body)
    msg  += "\nTotal sms count :#{json["total"]}"

    log msg.inspect

    log "Finished with get_volume_stats"
  end

  def send_mail(to, subject, msg)
    gmail          = GmailWorker.new
    gmail.domain   = email_domain
    gmail.username = email_username
    gmail.password = email_password
    gmail.from     = email_from
    gmail.to       = to
    gmail.subject  = "[Twilio] #{subject}"
    gmail.body     = msg
    gmail.queue
  end

end


