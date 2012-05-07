require 'iron_worker_ng'

p params

puts "ENV"
p ENV

puts "pwd: " + `pwd`
puts `ls -al`

@client = IronWorkerNG::Client.new(:token=>params['token'], :project_id=>params['project_id'])

puts `go build hello.go`

puts `ls -al`
