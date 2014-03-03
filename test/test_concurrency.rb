require_relative 'helpers'

class TestTmp < IWNGTest

  N_TASKS = 1
  puts 'here'

  def setup
    puts 'setup2'
    super

  end


  def test_max_concurrency
    name = 'text_max_concurrency'
    puts name

    worker_name = "sleepy"

    code = IronWorkerNG::Code::Base.new(:workerfile => "test/workers/#{worker_name}.worker")
    @client.codes.create(code)

    1.times do |i|
      puts "Queuing #{i}..."
      @client.tasks.create(worker_name,
                           {:sleep => 1*60, :i => i, :stathat => {:email => "travis@iron.io"}},
                           {:delay=>60}
      )
    end


  end


end
