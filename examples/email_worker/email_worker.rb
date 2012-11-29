# Configures smtp settings to send email.
def init_mail(username, password, domain, provider)
  puts "initializing provider"
  case provider
    when 'gmail'
      puts "Selected gmail as a provider"
      port = 587
      address = "smtp.gmail.com"
    when 'sendgrid'
      puts "Selected sendgrid as a provider"
      port = 25
      address = "smtp.sendgrid.net"
  end
  puts "Preparing mail configuration"
  mail_conf = {:address => address,
               :port => port,
               :domain => domain, #custom domain
               :user_name => username,
               :password => password,
               :authentication => 'plain',
               :enable_starttls_auto => true} #gmail require this option
  Mail.defaults do
    delivery_method :smtp, mail_conf
  end
  puts "Mail service configured"
end

def send_mail(to, from, subject, content)
  puts "Preparing email from:#{from},to:#{to},subject#{subject}"
  msg = Mail.new do
    to to
    from from
    subject subject
    html_part do |m|
      content_type 'text/html'
      body content
    end
  end
  puts "Mail ready, delivering"
  details = msg.deliver
  puts "Mail delivered!"
  details
end

def update_message_status(email, message_details)
  puts "Updating user status via API endpoint"
  puts "Email:#{email},details:#{message_details.inspect}"

  #here is the example how you could send email details from this worker to your api
  require 'rest'
  puts "initializing client"
  web_client = Rest::Client.new # res gem already merged
  puts "sending api request"
  #just change google.com on your api endpoint
  web_client.get('http://google.com', {:email => email, :message_details => message_details})

  # or put email details in iron_cache
  if params['iw_token'] && params['iw_project_id']
    puts "Initializing cache"
    require 'iron_cache'
    cache = IronCache::Client.new(:token => params['iw_token'], :project_id => params['iw_project_id'])
    puts "Sending message details to cache"
    cache.items.put(email, {:timestamp => Time.now, :message_details => message_details.inspect}.to_json)
  end

end

# Sample worker that sends an email.
puts "Worker started"

require 'mail'

init_mail(params['username'], params['password'], params['domain'], params['provider'])


if params['to'].is_a? Array # check what is passed one email or array of emails
  puts "Array of #{params['to'].count} emails passed"
  params['to'].each do |email|
    message_details = send_mail(email, params['from'], params['subject'], params['content'])
    update_message_status(email, message_details)
  end
else
  message_details = send_mail(params['to'], params['from'], params['subject'], params['content'])
  update_message_status(email, message_details)
end

puts "Worker finished"