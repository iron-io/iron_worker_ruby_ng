require './lib/iron_worker_ng.rb'
require 'test/unit'

class BasicTest < Test::Unit::TestCase
  attr_accessor :client

  def setup
    IronWorkerNG::Logger.logger.level = ::Logger::DEBUG

    token, project_id = [ ENV['IRON_IO_TOKEN'], ENV['IRON_IO_PROJECT_ID'] ]
    raise("please set $IRON_IO_TOKEN and $IRON_IO_PROJECT_ID " +
          "environment variables") unless token and project_id

    @client = IronWorkerNG::Client.new(:token => token,
                                       :project_id => project_id )
  end

  def test_basic
    code = IronWorkerNG::Code::Ruby.new('test_basic')
    code.merge_worker(File.dirname(__FILE__) + '/hello.rb')
    client.codes_create(code)
    task_id = client.tasks_create('test_basic').id
    client.tasks_wait_for(task_id)
    log = client.tasks_log(task_id)
    assert_equal( "hello\n", log, "worker stdout is in log" )
  end

  def test_30_codes
    31.times do |i|
      code = IronWorkerNG::Code::Ruby.new("test_30_codes_code#{i}")
      code.merge_worker(File.dirname(__FILE__) + '/hello.rb')
      client.codes_create(code)
    end
    assert_equal( 31, client.codes_list.size )
  end

end
