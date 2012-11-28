require "iron_worker_ng"

client = IronWorkerNG::Client.new

recipients = Array.new(10).fill{|i| "testuser+#{i}@gmail.com" }

batch = []
recipients.each_index do |i|
  puts "Processing #{i} --> #{recipients[i]}"
  batch << recipients[i]
  if i % 2 == 0
    puts "Sending batch of size #{batch.size}"
    client.tasks.create("IronMailer", :recipients => batch)
    batch = []
  end
end
