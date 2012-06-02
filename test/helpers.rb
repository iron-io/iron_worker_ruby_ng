gem 'test-unit'
require 'test/unit'
require 'tempfile'

require_relative '../lib/iron_worker_ng'

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

IronCore::Logger.logger.level = ::Logger::DEBUG

class IWNGTest < Test::Unit::TestCase
  attr_accessor :client

  def setup
    @client = IronWorkerNG::Client.new
  end

  def get_all_tasks
    prev_level = IronCore::Logger.logger.level
    IronCore::Logger.logger.level = ::Logger::INFO

    result = []
    page = -1
    begin
      tasks = client.tasks.list(:per_page => 100,
                                :page => page += 1)
      result += tasks
    end while tasks.size == 100

    IronCore::Logger.logger.level = prev_level

    result
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
