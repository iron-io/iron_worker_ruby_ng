require 'iron_mq'
require 'iron_worker_ng'

def queue_worker(config_data, to, subject, content)
  puts "Preparing worker params"
  # Create an IronWorker client
  client = IronWorkerNG::Client.new(:token => config_data['iw']['token'], :project_id => config_data['iw']['project_id'])
  email = config_data['email']
  #global params
  params = {:username => email['username'],
            :password => email['password'],
            :domain => email['domain'],
            :provider => email['provider']}

  #individual params
  params.merge!({
                    :from => email['from'],
                    :to => to,
                    :subject => subject,
                    :content => content
                })

  #adding iw token and project_id for IronCache if you don't use it you could remove following lines
  params.merge!({:iw_token => config_data['iw']['token'],
  :iw_project_id => config_data['iw']['project_id']})

  puts "Params ready, launching worker with #{to.count} emails"
  client.tasks.create("email_worker", params)
end


#simple get emails details from IronMQ queue
def get_emails(config_data)
  puts "initialize iron_mq client"
  ironmq = IronMQ::Client.new(:token => config_data['iw']['token'], :project_id => config_data['iw']['project_id'])

  emails = []
  n = 0

  #number of max emails that should be send with this worker per run
  max_emails_to_send = 100

  while n < max_emails_to_send
    puts "Gettig message from IronMQ"
    msg = ironmq.messages.get()
    puts "Got message from queue - #{msg.inspect}"
    break unless msg
    puts "Adding #{msg.body} to list of emails"
    emails << msg.body
    puts "Deleting message from queue"
    msg.delete
    n+=1
  end
  emails
end

def content
  <<-EOF
  <h1>Thank you for using Iron Worker</h1>
It's a simple email that has some html tags<br>
  <a href='http://iron.io'>Iron.io</a>
  EOF
end

puts "Started"
puts "Getting emails"
emails = get_emails(params)
puts "Received #{emails.count} emails"
#max number of emails per single worker
number_of_emails_per_worker = 10

#slice array of emails into small arrays with max 10 elems in each
sliced_emails = emails.each_slice(number_of_emails_per_worker).to_a

puts "Should be launched #{sliced_emails.count} workers"

sliced_emails.each do |array_of_emails|
  puts "Queueing worker"
  queue_worker(params, array_of_emails, "Welcome email", content)
end
puts "Worker done"
