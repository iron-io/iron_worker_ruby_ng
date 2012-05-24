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
    client.codes.create( code_bundle(:name => 'test_schedule') do
                           worker_code 'sleep 10 and puts "hello"'
                         end )

    start = (Time.now + 10).utc

    id = client.schedules.create('scheduler_quick', :start_at => start).id
    sleep 5 until client.schedules.get(id).status == 'complete'

    task = get_all_tasks.
      keep_if{ |t| t.code_name == 'scheduler_quick' }.
      max_by{ |t| Time.parse t.start_time }

    client.tasks.wait_for task.id

    puts "planned start: ", start
    puts "actual start: ", Time.parse(task.start_time)

    # if fails, ensure local time is correct, try ntpdate
    assert Time.parse(task.start_time) >= start

    assert Time.parse(task.start_time) + 10 <= Time.parse(task.end_time)
    assert_equal 'complete', task.status
    assert_equal "hello\n", client.tasks.log(task.id)
  end

end
