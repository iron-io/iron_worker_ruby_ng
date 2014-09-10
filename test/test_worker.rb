require_relative 'helpers'

class WorkerTest < IWNGTest

  def test_concurrency
    client.codes.create(IronWorkerNG::Code::Base.new('test/sleep'), {max_concurrency: 5})
    tasks = []
    10.times do
      tasks.push client.tasks.create('sleep', {:sleep => 120}).id
    end

    sleep 60
    running = 0
    queued = 0
    tasks.each do |task|
      running +=1 if client.tasks.get(task).status == 'running'
      queued +=1 if client.tasks.get(task).status == 'queued'
      client.tasks.cancel(task)
    end

    assert_equal 5, running
    assert_equal 5, queued

  end

  def test_workers
    test_workers=Dir.entries('/home/freeman/projects/ironproj/iron_worker_ruby_ng/test/worker-test/'); test_workers.delete('.'); test_workers.delete('..')
    test_workers.each do |test_worker|
      client.codes.create(IronWorkerNG::Code::Base.new("test/worker-test/#{test_worker}/#{test_worker}"))
      id = client.tasks.create(test_worker).id
      task = client.tasks.wait_for(id)

      if test_worker == 'mem-kill'
        puts '='*10
        puts task
        assert_equal 'error', task.status
        assert_equal "Killed\n", task.msg
      else
        assert_equal 'complete', task.status
      end
    end
  end

end
