require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'minitest/unit'
require 'minitest/reporters'
require 'tempfile'
require 'optparse'

require_relative '../lib/iron_worker_ng.rb'
require_relative 'iron_io_config.rb'

def code_bundle(*args,&block)
  code = IronWorkerNG::Code::Base.new(*args)

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
  zip_file = code.create_container
  yield Zip::ZipFile.open(zip_file)
  File.unlink zip_file
end

IronCore::Logger.logger.level = ::Logger::DEBUG

class IWNGTest < Test::Unit::TestCase
  attr_accessor :client

  def setup
    options = { env: 'staging' }
    OptionParser.new do |opts|
      opts.on('--project-id PROJECT_ID', String) do |p|
        options[:project_id] = p
      end
    end.parse!

    @client = IronWorkerNG::Client.new options
  end

  def get_all_tasks(options = { :from_time => (Time.now - 60 * 60).to_i })
    prev_level = IronCore::Logger.logger.level
    IronCore::Logger.logger.level = ::Logger::INFO

    result = []
    page = -1
    begin
      tasks = client.tasks.list({ :per_page => 100,
                                  :page => page += 1
                                }.merge(options))
      result += tasks
    end while tasks.size == 100

    IronCore::Logger.logger.level = prev_level

    result
  end

  def cli(*args)
    if args.last.is_a? Hash
      args.pop.each do |k,v|
        args << "--" + k.to_s.gsub(/_/,'-') + " " + v.to_s
      end
    end

    args << '--debug'

    out = Tempfile.new('cli_output').path
    args << "2>&1 >#{out}"

    test_dir = File.dirname(__FILE__)
    cmd = "ruby -I#{test_dir}/../lib #{test_dir}/cli_runner.rb " + args.join(' ')
    puts cmd

    exec(cmd) if fork.nil?
    Process.wait

    puts "--- cli output begin -------------------------------------"

    puts File.read(out)

    puts "--- cli output end ---------------------------------------"

    puts $?
    assert $?.success?

    File.read(out)
  end
end

class Test::Unit::UI::Console::TestRunner
  def guess_color_availability
    false
  end
end
