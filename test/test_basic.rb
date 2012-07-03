require 'helpers'

class BasicTest < IWNGTest
  def test_basic
    code = IronWorkerNG::Code.new do
      name 'test_basic'
      exec(File.dirname(__FILE__) + '/hello.rb')
    end

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
