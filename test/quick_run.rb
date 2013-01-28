require_relative 'helpers'

class QuickRun < IWNGTest

  N_TASKS = 100

  def setup
    super

  end

  def test_quick_run2

    client.codes.create(IronWorkerNG::Code::Base.new('hello'))

    task_ids = []
    N_TASKS.times do |i|
      puts "#{i}"
      task_ids << client.tasks.create('hello', {:foo=>"bar"}, {:priority=>2}).id
    end

    task_ids.each_with_index do |id, i|
      puts "#{i}"
      task = client.tasks.wait_for(id)
      p task
      assert_equal 'complete', task.status
      log = client.tasks.log(id)
      puts log
      assert_equal "hello\n", log
    end
  end

end
