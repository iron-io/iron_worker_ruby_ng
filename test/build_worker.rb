require 'iron_worker_ng'

p params

puts "ENV"
p ENV

puts "pwd: " + `pwd`
puts `ls -al`

puts `go build hello.go`

puts `ls -al`

# todo: remove this next line, just for testing
puts `./hello`

puts "Uploading code..."
@client = IronWorkerNG::Client.new(params)
code = IronWorkerNG::Code::Binary.new()
code.name = params['name']
code.merge_exec "hello"
p @client.codes_create(code)

