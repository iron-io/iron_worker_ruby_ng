require 'action_mailer'
require 'mailer' # current dir is in load path already

# let's configure actionmailer...
ActionMailer::Base.smtp_settings = {
  :user_name => params['gmail']['username'],
  :password => params['gmail']['password'],
  :address => "smtp.gmail.com",
  :port => 587,
  :domain => 'gmail.com',
  :authentication => 'plain',
  :enable_starttls_auto => true
}

ActionMailer::Base.view_paths = ['.'] # it should know where to look for templates

# ...and deliver some messages
params['to'].each do |to|
  puts "Sending mail from #{params['from']} to #{to}"
  Mailer.test_email(params['from'], to).deliver!
end
