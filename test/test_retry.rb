require_relative 'helpers'

class RetryTest < IWNGTest

  def test_retry
    code = IronWorkerNG::Code::Base.new do
      name 'hello'
      exec 'test/hello.rb'
    end
    client.codes.create(code)

    # queue
    task_id = client.tasks.create('hello').id
    client.tasks.wait_for(task_id)

    # retry
    task_id = client.tasks.retry(task_id).id
    client.tasks.wait_for(task_id)

    assert_equal "hello\n", client.tasks.log(task_id)
  end


  def test_auto_retry
    name = 'test_auto_retry'

    tasks = 1
    retries = 3
    retries_delay = 5

    client.codes.create(code_bundle(:name => name,
                                    :exec => 'test/workers/fail_worker.rb'),
                        :retries => retries,
                        :retries_delay => retries_delay)

    task_ids = []
    tasks.times do
      task_ids << client.tasks.create(name, {}, {:priority => 2}).id
    end

    task_ids.each do |id|
      j = 0
      tid = id
      while tid != nil
        task = client.tasks.wait_for(tid)
        p task
        puts "retry_num: #{task.retry}"
        puts "original_task_id: #{task.original_task_id}"
        puts "retry_task_id: #{task.retry_task_id}"
        assert_equal 'error', task.status
        log = client.tasks.log(id)
        assert log.include?("Fail Whale")
        assert task.retry_task_id if j < retries
        tid = task.retry_task_id
        if j > 0
          assert_equal retries_delay, task.delay
        end
        j += 1
      end
      assert_equal retries+1, j
    end
  end

end
