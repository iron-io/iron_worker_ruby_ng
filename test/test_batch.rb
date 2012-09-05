require 'helpers'
require 'thread'

class BatchTest < IWNGTest

  N_TASKS = 10

  def test_batch
    client.codes.create code_bundle(:name => 'test',
                                    :exec => 'test/hello.rb')

    task_ids = []
    mutex = Mutex.new
    (N_TASKS.times.map do
       Thread.new do
         task_id = client.tasks.create('test').id
         mutex.synchronize do
           task_ids << task_id
         end
       end
     end).each{|t| t.join}

    assert_equal N_TASKS, task_ids.size,
                 "All tasks started"

    task_ids.each do |id|
      client.tasks.wait_for(id)
      assert_equal "hello\n", client.tasks.log(id),
                   "correct output"
    end
  end

end
