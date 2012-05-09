require 'helpers'

class BasicTest < IWNGTest
  def test_basic
    code = IronWorkerNG::Code::Ruby.new
    code.merge_exec(File.dirname(__FILE__) + '/hello.rb')
    client.codes_create(code)
    task_id = client.tasks_create('test_basic').id

    task = client.tasks_wait_for(task_id)
    assert task
    assert task.id == task_id
    assert_equal "complete",  task.status
    assert_equal 1,           task.run_times
    assert_equal "{}",        task.payload

    log = client.tasks_log(task_id)
    assert_equal( "hello\n", log, "worker stdout is in log" )
  end
end
