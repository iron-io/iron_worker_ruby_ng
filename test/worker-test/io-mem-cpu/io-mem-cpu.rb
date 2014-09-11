max_mem = params['max_mem']
max_hdd = params['max_hdd']
cpu = params['cpu']
errors = []

#######---CPU CHECK---#######
loop_t1_finished = false

def pi_calc(den_len)
  num = 4.0
  pi = 0
  plus = true

  den = 1
  while den < den_len
    if plus
      pi = pi + num/den
      plus = false
    else
      pi = pi - num/den
      plus = true
    end
    den = den + 2
  end
  pi
end

t1=Thread.new{pi=pi_calc(25000000); puts "PI = #{pi}"; loop_t1_finished = true}

count=0
t2 = Thread.new do
  loop do
    count += 1
    Thread.exit if loop_t1_finished
    puts `ps aux | awk {'sum+=$3;print sum'} | tail -n 1`
    sleep(1)
  end
end

t2.join

case cpu
  when 1
    expected_seconds = 2
  when 2
    expected_seconds = 5
  when 3
    expected_seconds = 10
  else
    expected_seconds = 5
end
if count > expected_seconds
  errors.push "CPU test: Current execution time (#{count}) is not as expected"
end
#execution time ~ < 5sec



#######---HDD CHECK---#######
available = `df -m  2>&1 | head -n 2 | tail -n 1 | awk '{print $2}'`

if available.to_i < max_hdd - 500
  errors.push "HDD test: Current available size (#{available}) is not as expected"
end
#should be >9500 && <10000



#######---NETWORK CHECK---#######
require 'open-uri'
url = 'https://s3.amazonaws.com/iron-examples/video/iron_man_2_trailer_official.flv'
start = Time.now
filename = 'video.flv'

open(filename, 'wb') do |file|
  file << open(url).read
end

file_size = (File.size(filename).to_f / 2**20).round(2)
puts file_size

elapsed_time = Time.now - start
if elapsed_time > 20
  errors.push "Network test: Elapsed time is greater than 20 sec #{elapsed_time.to_s}"
end
if file_size < 20
  errors.push "Network test: Current downloaded file size(#{file_size}) is not as expected"
end
#elapsed time < 20 sec
#file size >20mb && <25mb


unless errors.empty?
  puts errors
  abort
end

#######---MEM CHECK---#######
a = "x" * (max_mem * 1000 * 1000 - 20_000_000)
