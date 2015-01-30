require_relative 'helpers'

class BasicTest < IWNGTest
  def test_basic
    create_code('test_basic')
    task_id = client.tasks_create('test_basic').id

    task = client.tasks_wait_for(task_id)

    assert task
    assert task.id == task_id
    assert_equal "complete",  task.status
    assert_equal "{}",        task.payload

    log = client.tasks_log(task_id)
    assert_equal( "hello\n", log, "worker stdout is in log" )
  end

  def test_task_label
    create_code('test_label')
    resp = client.tasks.create('test_label', {}, label: 'new_label' )
    task = client.tasks.get(resp.id)
    assert_equal "new_label", task.label
  end

  def test_schedule_label
    create_code('test_label')
    resp = client.schedules.create('test_label', {}, start_at: Time.now + 120, run_times: 1, label: 'schedule_label' )
    task = client.schedules.get(resp.id)
    assert_equal "schedule_label", task.label
  end

  def test_pause_task_queue
    code_id = create_code('test_paused_task')
    response = client.codes.pause_task_queue(code_id)
    task_ids = []
    10.times do
      task_ids << client.tasks.create('test_paused_task').id
    end
    paused_code = client.codes.get(code_id)
    assert_equal 'Paused', response['msg']
    assert_equal -1, paused_code.max_concurrency
    sleep 10
    task_ids.each do |id|
      task = client.tasks.get(id)
      assert_equal 'queued', task.status
    end
    client.codes.resume_task_queue(code_id)
  end

  def test_resume_task_queue
    code_id = create_code('test_resumed_task')
    client.codes.pause_task_queue(code_id)
    task_ids = []
    5.times do
      task_ids << client.tasks.create('test_resumed_task').id
    end
    sleep 5
    response = client.codes.resume_task_queue(code_id)
    resumed_code = client.codes.get(code_id)
    assert_equal 'Resumed', response['msg']
    assert_not_equal -1, resumed_code.max_concurrency
    sleep 5
    task_ids.each do |id|
      task = client.tasks.get(id)
      assert_send([['running', 'complete'], :include?, task.status])
    end
  end

  def create_code(name)
    code = code_bundle(exec: 'test/hello.rb', name: name)
    client.codes.create(code).id
  end
end
