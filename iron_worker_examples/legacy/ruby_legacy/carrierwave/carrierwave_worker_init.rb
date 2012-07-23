require 'yaml'
require 'carrierwave'
require 'fog'

require_relative 'sample_uploader'
require_relative 'carrierwave_configure'

puts "\nConfiguring CarrierWave with your AWS credentials...\n\n"
conf = YAML.load_file 'carrierwave.yml'
carrierwave_configure(conf['aws']['access_key'], conf['aws']['secret_key'], conf['aws']['bucket'])

puts "Creating a standard CarrierWave uploader and sending the sample images to S3...\n\n"
uploader = SampleUploader.new
uploader.store!(File.new(conf['image_file']))

puts "Creating a sample HTML file for easy display...\n\n"
File.open("demo.html", "w") do |f|
  f.puts "<h2>The original file</h2>"
  f.puts "<img src=\"#{uploader.url}\" /> <br /><br />"
  f.puts "<h3>The following 3 files will show once your worker runs</h2>"
  f.puts "<h2>Resized</h2>"
  f.puts "<img src=\"#{File.dirname(uploader.url)}/processed-1.png\" /> <br /><br />"
  f.puts "<h2>Sketched</h2>"
  f.puts "<img src=\"#{File.dirname(uploader.url)}/processed-2.png\" /> <br /><br />"
  f.puts "<h2>Rotated</h2>"
  f.puts "<img src=\"#{File.dirname(uploader.url)}/processed-3.png\" /> <br /><br />"
end


puts "Finished!  Now do the following: \n"
puts "1. Open up demo.html in your browser"
puts "2. run 'ruby carrierwave_worker_runner.rb'.  This will upload and queue your worker into the IronWorker platform."
puts "3. Visit your jobs list page to see the worker running.  This should only take a few seconds."
puts "4. Refresh demo.html\n\n\n"


