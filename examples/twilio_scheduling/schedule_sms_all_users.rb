require 'iron_worker_ng'
require 'uber_config'

@config = UberConfig.load
@iw = IronWorkerNG::Client.new

# Generally, you would pass in your database credentials or info to access some data source, but
# for this example, we'll just make a list of users:
users = [
    {user_id: '123', phone_number: @config[:to]},
    {user_id: '456', phone_number: nil}, # nil number here so it doesn't actually send it
    {user_id: '789', phone_number: nil}
]

# @iw.options merges the config that was loaded into the IronWorkerNG::Client, which is your iron.json file in this case.

payload = {iron: @iw.api.options}.merge(@config).merge(users: users)
p payload
@iw.schedules.create("sms_all_users",
                     payload,
                     {
                         #This is the schedule
                         :start_at => Time.now,
                         :run_every => 60,
                         :run_times => 2
                     })
