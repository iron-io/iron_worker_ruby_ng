require 'test/unit'
require 'tempfile'

require './lib/iron_worker_ng.rb'

def code_bundle(*args,&block)
  code = IronWorkerNG::Code::Ruby.new(*args)

  class << code
    def worker_code(str)
      tmpdir = Dir.tmpdir + '/' + Digest::MD5.hexdigest(str)
      Dir.mkdir tmpdir unless Dir.exist? tmpdir

      tmpfname = tmpdir + '/worker.rb'
      File.open(tmpfname, "w") { |f| f << str }

      puts "created #{tmpfname}"
      merge_exec(tmpfname)
    end
  end

  code.instance_eval(&block) if block_given?

  code
end

def inspect_zip(code)
  zip_file = code.create_zip
  yield Zip::ZipFile.open(zip_file)
  File.unlink zip_file
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

module IronWorkerNG
  module Code
    class Base
      def exec_path
        exec = @features.find{|f| f.is_a? IronWorkerNG::Feature::Ruby::MergeExec::Feature } and exec.path
      end
    end
  end
end
