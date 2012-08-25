require_relative 'helpers'

class QuickRun < IWNGTest

  N_TASKS = 1

  def setup
    super

  end

  def test_auto_retry
    name = 'test_auto_retry'
    client.codes.create(code_bundle(:name => name,
                                    :exec => 'workers/fail_worker.rb'
                        ), :num_retries => 3)

    task_ids = []
    N_TASKS.times do
      task_ids << client.tasks.create(name, {}, {:priority => 2}).id
    end

    task_ids.each do |id|
      task = client.tasks.wait_for(id)
      p task
      puts "retry_num: #{task.retry}"
      puts "original_task_id: #{task.original_task_id}"
      puts "retry_task_id: #{task.retry_task_id}"
      assert_equal 'error', task.status
      log = client.tasks.log(id)
      assert log.include?("Fail Whale")
      assert task.retry_task_id

    end
  end

end
