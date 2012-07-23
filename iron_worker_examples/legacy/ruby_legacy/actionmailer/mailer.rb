class Mailer < ActionMailer::Base
  default :from => "somename@host.com"
  def test_email(to)
    mail(:to=>to,
    :subject=>"Sample subject")
  end

end
