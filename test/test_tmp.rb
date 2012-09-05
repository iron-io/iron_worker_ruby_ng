require_relative 'helpers'

class TestTmp < IWNGTest

  N_TASKS = 1

  def setup
    puts 'setup2'
    super

  end


  def text_max_concurrency
    name = 'text_max_concurrency'
    puts name

    worker_name = "sleepy"

    code = IronWorkerNG::Code::Base.new(:workerfile => 'workers/sleepy.worker')
    code.name = worker_name
    @iron_worker.codes.create(code, :max_concurrency => 10)

    @iron_worker = IronWorkerNG::Client.new()
    100.times do |i|
      puts "Queuing #{i}..."
      @iron_worker.tasks.create(worker_name, {:sleep => 1*60, :i => i, :stathat => {:email => "travis@iron.io"}})
    end


  end


end
