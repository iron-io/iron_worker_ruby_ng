require 'iron_worker'

class MailerWorker < IronWorker::Base

  merge_gem 'actionmailer',{:require=>'action_mailer',:version=>'3.0.9'}
  merge_mailer 'mailer', {:path_to_templates=>"mailer"}

  attr_accessor :gmail_user_name,:gmail_password,:email_send_to
  
  def run
    ActionMailer::Base.smtp_settings={
        :address => "smtp.gmail.com",
        :port => 587,
        :domain => 'gmail.com',
        :user_name => gmail_user_name,
        :password => gmail_password,
        :authentication => 'plain',
        :enable_starttls_auto => true}
    Mailer.test_email(email_send_to).deliver!
  end
end