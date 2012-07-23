class LogglyWorker < IronWorker::Base
  merge_gem 'logglier'

  attr_accessor :loggly_key, :i

  def run
    puts "I'm going to start logging to loggly... right... now!"
    log = Logglier.new("https://logs.loggly.com/inputs/#{loggly_key}")

    log.info("I am now logging to Loggly #{i} times.")
  end
end
