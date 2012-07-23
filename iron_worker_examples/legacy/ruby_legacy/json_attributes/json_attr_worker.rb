require 'iron_worker'

class JsonAttrWorker < IronWorker::Base

  merge 'my_model'

  attr_accessor :object

  def run
    puts "Hello there, here's an object attribute:"
    p object
  end


end