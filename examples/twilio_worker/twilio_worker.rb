require 'twilio-ruby'
puts "Running TwilioSMSWorker..."

puts "Connecting to Twilio..."
client = Twilio::REST::Client.new(params['sid'], params['token'])
puts "Connected."

puts "Sending a text message..."
client.account.sms.messages.create(
    :from => params['from'],
    :to => params['to'],
    :body => params['message']
)

puts "Sent."

puts "Finished processing TwilioSMSWorker."