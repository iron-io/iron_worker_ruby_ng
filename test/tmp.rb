require_relative 'helpers'

class QuickRun < IWNGTest

  N_TASKS = 1

  def setup
    super

  end

  def test_auto_retry
    name = 'test_auto_retry'

    retries = 3
    retries_delay = 5

    client.codes.create(code_bundle(:name => name,
                                    :exec => 'workers/fail_worker.rb'),
                        :retries => retries,
                        :retries_delay => retries_delay)

    task_ids = []
    N_TASKS.times do
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
        j += 1

      end

    end
  end

end
