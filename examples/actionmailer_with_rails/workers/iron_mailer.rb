require 'active_support/core_ext'
require 'action_mailer'
require 'models/mailer'

# Parse our config yaml file
config = YAML.load_file("settings.yml")

# A nifty Ruby line to set the AM settings from our loaded yaml file
ActionMailer::Base.smtp_settings = config['sendgrid'].inject({}) { |memo, (k, v)| memo[k.to_sym] = v; memo }

# Set AM's view path
ActionMailer::Base.view_paths = ['.']

# Deliver the email
params[:recipients].each do |r|
  Mailer.hello_world(r).deliver!
end
