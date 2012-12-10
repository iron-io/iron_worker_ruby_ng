ranges = [1, 10, 100]
require 'iron_worker_ng'
times = {}
ranges.each do |r|
  start_time = Time.now
  threads = []
  r.times do |i|
    client = IronWorkerNG::Client.new()
    threads << Thread.new {
      t = client.tasks.create(
          'ImageProcessor',
          'disable_network' => true
      )
      client.tasks.wait_for(t.id) do |task|
        puts task.status
      end
    }
  end
  threads.each(&:join)
  puts "Processing time = #{Time.now - start_time}"
  times[r] = Time.now - start_time
end
File.open("remote_times.stat", "w") do |file|
  file.write times.to_s
end
