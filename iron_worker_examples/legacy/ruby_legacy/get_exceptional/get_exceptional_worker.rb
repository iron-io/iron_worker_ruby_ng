require 'iron_worker'

class GetExceptionalWorker< IronWorker::Base

  attr_accessor :api_key

  merge_gem 'exceptional'

  def run
    Exceptional::Config.api_key = api_key
    Exceptional::Config.enabled = true
    Exceptional.rescue do
      raise "Exception should be sent to getexceptional"
    end

  end
end

