require 'helpers'

class BasicTest < IWNGTest
  def _test_basic
    code = IronWorkerNG::Code::Ruby.new('test_basic')
    code.merge_worker(File.dirname(__FILE__) + '/hello.rb')
    client.codes_create(code)
    task_id = client.tasks_create('test_basic').id
    client.tasks_wait_for(task_id)
    log = client.tasks_log(task_id)
    assert_equal( "hello\n", log, "worker stdout is in log" )
  end
end
