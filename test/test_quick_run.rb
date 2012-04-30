require 'helpers'

class QuickRunTest < IWNGTest

  N_TASKS = 50

  def setup
    super
    client.codes.create code_bundle(:name => 'test',
                                    :exec => 'test/hello.rb')
  end

  def test_quick_run
    task_ids = []
    N_TASKS.times do
      task_ids << client.tasks.create('test').id
    end

    task_ids.each do |id|
      task = client.tasks.wait_for(id)
      assert_equal 'complete', task.status
      assert_equal "hello\n", client.tasks.log(id)
    end
  end

  def test_scheduler_quick
    client.codes.create code_bundle(:name => 'test_schedule',
                                    :exec => 'test/hello.rb')

    id = client.schedules.create('test_schedule', :start_at => Time.now + 10).id
    sleep 5 until client.schedules.get(id).status != 'complete'

    task = get_all_tasks.find{ |t| t.code_name == 'test_schedule' }

    assert task
    assert_equal 'complete', task.status
    assert_equal "hello\n", client.tasks.log(task.id)
  end

end
