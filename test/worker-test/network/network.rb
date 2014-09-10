require 'open-uri'
url = "https://s3.amazonaws.com/iron-examples/video/iron_man_2_trailer_official.flv"
start = Time.now
filename = 'video.flv'

open(filename, 'wb') do |file|
  file << open(url).read
end

file_size = (File.size(filename).to_f / 2**20).round(2)
puts file_size

elapsed_time = Time.now - start
if elapsed_time > 20
  puts "Elapsed time is greater than 20 sec #{elapsed_time.to_s}"
  abort
end
if file_size < 20
  puts "Current file size(#{file_size}) is not as expected"
  abort
end

#elapsed time < 20 sec
#file size >20mb && <25mb
