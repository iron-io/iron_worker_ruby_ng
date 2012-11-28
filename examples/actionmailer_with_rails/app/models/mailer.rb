class Mailer < ActionMailer::Base
  layout 'email'
  default :from => "default@somedomain.com"

  def hello_world(email)
    mail(:to => email,
         :subject => "Hello World from IronWorker!")
  end

end
