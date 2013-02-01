require_relative 'helpers'

class TestTmp < IWNGTest

  N_TASKS = 1
  puts 'here'

  def setup
    puts 'setup2'
    super

  end


  def test_config

    client.codes.create(IronWorkerNG::Code::Base.new('workers/config_worker'), {config: {c1: "some config var"}})

    task_ids = []
    N_TASKS.times do |i|
      puts "#{i}"
      task_ids << client.tasks.create('config_worker', {:foo=>"bar"}).id
    end

    task_ids.each_with_index do |id, i|
      puts "#{i}"
      task = client.tasks.wait_for(id)
      p task
      assert_equal 'complete', task.status
      log = client.tasks.log(id)
      puts log
      assert log.include?("some config var")
    end

  end


end
