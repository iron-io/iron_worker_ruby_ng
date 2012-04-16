require 'test/unit'
require 'tempfile'

require './lib/iron_worker_ng.rb'

def code_bundle(name,&block)
  code = IronWorkerNG::Code::Ruby.new(name)

  class << code
    def worker_code(str)
      Tempfile.open('worker') do |f|
        f << str
        f.close
        merge_worker(f.path)
        f.unlink
      end
    end
  end

  code.instance_eval(&block)

  code
end

class IWNGTest < Test::Unit::TestCase
  attr_accessor :client

  def setup
    IronWorkerNG::Logger.logger.level = ::Logger::DEBUG

    token, project_id = [ ENV['IRON_IO_TOKEN'], ENV['IRON_IO_PROJECT_ID'] ]
    raise("please set $IRON_IO_TOKEN and $IRON_IO_PROJECT_ID " +
          "environment variables") unless token and project_id

    @client = IronWorkerNG::Client.new(:token => token,
                                       :project_id => project_id )
  end
end
