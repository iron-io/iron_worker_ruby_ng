# This worker simply calls back to a URL in your application. Great for performing some action
# on your application on a schedule

require 'iron_worker'


class CallbackWorker < IronWorker::Base

  merge_gem 'httparty'

  attr_accessor :callback_url

  def run

    puts "posting to #{callback_url}"
    resp = HTTParty.post(callback_url, {:body=>{:x=>"y"}})
    p resp
    
  end

end
