# Inputs
#
#   twilio:
#     sid: your twilio sid
#     token: your twilio token
#     from: your twilio phone number
#   to: "the phone number to send to"
#   body: "The message to send"
#

require 'twilio-ruby'
require 'uber_config'

# little worker hack to run it locally
begin
  @config = UberConfig.load()
  @params = @config
rescue => ex
  @config = params
end

sid = @config['twilio']['sid']
token = @config['twilio']['token']
from = @config['twilio']['from']
to = @params['to']
i = @params['i']

# LOOK HERE!
# This is where we can generate a custom message for the user!
# Pull in data from your database, from API's, etc. Maybe crunch it into something interesting...
# But for now, we'll just set it to this:
body = "Hello from IronWorker! ##{i}"

# set up a client to talk to the Twilio REST API
@client = Twilio::REST::Client.new sid, token

if to
# And finally, send the message
  r = @client.account.sms.messages.create(
      :from => from,
      :to => to,
      :body => body
  )
  p r
end
