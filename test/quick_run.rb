require_relative 'helpers'

require 'go'

class QuickRun < IWNGTest

  N_TASKS = 100

  def setup
    super

  end

  def test_quick_run2

    client.codes.create(IronWorkerNG::Code::Base.new('hello'))

    task_ids = []
    ch = Go::Channel.new
    N_TASKS.times do |i|
      go do
        puts "#{i}"
        ch << client.tasks.create('hello', {:foo => "bar"}, {:priority => 2}).id
      end
    end

    ch.each do |x|
      task_ids << x
      break if task_ids.size == N_TASKS
    end

    task_ids.each_with_index do |id, i|
      puts "#{i}"
      task = client.tasks.wait_for(id)
      p task
      assert_equal 'complete', task.status
      #log = client.tasks.log(id)
      #puts log
      #assert_equal "hello\n", log, "for #{i}th task, task_id: ##{id}"
    end
  end

end
