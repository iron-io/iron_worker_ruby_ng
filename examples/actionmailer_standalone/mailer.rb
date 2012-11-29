class Mailer < ActionMailer::Base
  def test_email(from, to)
    mail(:from => from, :to => to, :subject => 'Sample subject')
  end
end
