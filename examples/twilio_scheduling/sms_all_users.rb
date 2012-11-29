# Generally, you would look up your users in your database, for eg:
#
# User.each do |user|
#   @iw.tasks.create('sms', params.merge(user_id: user.id, to: user.phone_number))
# end
#
# But for this example, an array of user_ids is included in the payload.

require 'iron_worker_ng'
require 'uber_config'

p params
puts '@params'
p @params

# Here is our users array
users = @params[:users]

# little worker hack to run it locally
begin
  @config = UberConfig.load()
  @params = @config
rescue => ex
  @config = @params
end

@iw = IronWorkerNG::Client.new(@config[:iron])

users.each_with_index do |user, i|
  # Creating a task for each user
  @iw.tasks.create('sms', @params.merge(i: i, user_id: user[:user_id], to: user[:phone_number]))
end
