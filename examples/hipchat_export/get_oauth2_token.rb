require 'google_drive'
require 'oauth2'
require 'launchy'
require 'yaml'


# Get client_id and secret from Google: https://code.google.com/apis/console
# Be sure to create an application the Google API Console that is an "installed application"
# Update config.yml with thes values
config = YAML.load_file("config.yml")
google_client_id = config["google_client_id"]
google_secret = config["google_secret"]
redirect_url = "urn:ietf:wg:oauth:2.0:oob" # This is used for desktop apps

client = OAuth2::Client.new(
    google_client_id,
    google_secret,
    :site => "https://accounts.google.com",
    :token_url => "/o/oauth2/token",
    :authorize_url => "/o/oauth2/auth")
auth_url = client.auth_code.authorize_url(
    :redirect_uri => redirect_url,
    :scope => "https://docs.google.com/feeds/ " +
        "https://docs.googleusercontent.com/ " +
        "https://spreadsheets.google.com/feeds/")

Launchy.open(auth_url)

sleep 2

puts "Enter the auth code you get in your browser: "
authorization_code = gets
puts "Got auth code: #{authorization_code}"
puts "Getting token..."

# Redirect the user to auth_url and get authorization code from redirect URL.
auth_token = client.auth_code.get_token(
    authorization_code,
    :redirect_uri => redirect_url)

puts "Verifying token..."

session = GoogleDrive.login_with_oauth(auth_token)

for file in session.files
  p file.title
end

puts "Your auth_token is: #{auth_token.token}"
puts "Your refresh token is: #{auth_token.refresh_token}"
