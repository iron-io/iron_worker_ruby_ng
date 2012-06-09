require 'iron_worker_ng'

p params

puts "ENV"
p ENV

puts "pwd: " + `pwd`
puts `ls -al`

class WorkerFile

  attr_accessor :wruntime,
                :wname,
                :exec_file,
                :files,
                :gems,
                :build_command

  def initialize(raw)
    @files = []
    @gems = []

    puts 'evaling'
    eval(raw)
    puts 'done evaling '
  end

  def runtime(s)
    @wruntime = s
  end

  def exec(s)
    @exec_file = s
  end

  def name(s)
    @wname = s
  end

  def file(s)
    @files << s
  end

  def gem(s)
    @gems << s
  end

  def build_command(s=nil)
    if s
      @build_command = s
    end
    @build_command
  end

end


code = nil

def get_code_by_runtime(runtime)
  if runtime == "ruby"
    return IronWorkerNG::Code::Ruby.new()
  elsif runtime == "binary"
    return IronWorkerNG::Code::Binary.new()
  else
    raise "No runtime found for #{runtime}!"
  end
end

if params['worker_file_url']
  wfurl = params['worker_file_url']
  puts "worker_file_url: #{wfurl}"
  if wfurl.include?("github.com")
    require 'open-uri'

    raw_url = wfurl.sub("blob", "raw")
    p raw_url

    raw = open(raw_url).read
    puts "raw worker file:\n#{raw}"

    worker_file = WorkerFile.new(raw)
    puts "worker_file: " + worker_file.inspect

    endpoint_dir = File.dirname(raw_url)
    puts "endpoint_dir: " + endpoint_dir

    get_files = worker_file.files
    unless worker_file.build_command
      # need to build first, exec isn't on server
      get_files += [worker_file.exec_file]
    end
    get_files.each do |f|
      open(f, 'w') do |file|
        url = "#{endpoint_dir}/#{f}"
        puts "Getting #{url}"
        file << open(url).read
      end
    end

    code = get_code_by_runtime(worker_file.wruntime)

    if worker_file.gems && worker_file.gems.size > 0
      open("Gemfile", 'w') do |gemfile|
        gemfile << "source 'http://rubygems.org'\n"
        worker_file.gems.each do |gem|
          gemfile << "gem '#{gem}'\n"
        end
      end

      puts `ls -al`

      # now build bundle
      puts "building bundle"
      puts `bundle install --standalone`
      code.merge_dir 'bundle'
    end


    if worker_file.build_command
      puts `#{worker_file.build_command}`
    end


    code.name = params['name'] || worker_file.wname
    code.merge_exec worker_file.exec_file
    worker_file.files.each do |f|
      code.merge_file f
    end

  else
    raise "I don't know how to get your worker code from this location."
  end
end

if params['build_command']
  puts "build_commmand: #{params['build_command']}"
  puts `#{params['build_command']}`
  code = IronWorkerNG::Code::Binary.new()
  code.name = params['name']
  code.merge_exec params['exec']

end


puts `ls -al`

# just for testing
#puts `./hello`

puts "Uploading code..."
@client = IronWorkerNG::Client.new(params)
p @client.codes_create(code)

