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
    id = client.schedules.create(:start_at => Time.now + 10).id
    sc = client.schedules.wait_for(id)
    assert_equal id, sc.id
    assert_equal "complete", sc.status
    assert_equal "hello\n", client.schedules.log(sc.id)
  end

end
