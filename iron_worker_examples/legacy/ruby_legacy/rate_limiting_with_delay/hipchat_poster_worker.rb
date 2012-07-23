require 'iron_worker'

class HipchatPosterWorker < IronWorker::Base

  merge_gem 'hipchat-api'
  merge_gem 'rest-client'

  attr_accessor :hipchat_api_key,
                :hipchat_room_name,
                :twitter_keyword,
                :n,
                :delay

  def run
    client = HipChat::API.new(hipchat_api_key)
    notify_users = false
    puts "posting to hipchat: "
    puts client.rooms_message(hipchat_room_name, 'IronWorker', "Hello! I am number #{n} with delay of #{delay}", notify_users).body

  end

end
