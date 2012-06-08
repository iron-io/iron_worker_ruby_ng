require 'hipchat'
require 'aws/s3'
require 'tmpdir'
require 'json'
require 'cgi'

push = JSON.parse(CGI::parse(payload)['payload'][0])

exit(0) unless push[:ref] =~ /master/

config = JSON.parse( File.read('.abt-ng-config'),
                     :symbolize_names => true )

msg = "#{push['pusher']['name']} have pushed:\n" +
  ( push['commits'].map do |c|
      "<a href=\"#{c['url']}\">#{ CGI::escapeHTML(c['message']) }</a>" +
        " by #{c['author']['name']}"
    end.join("\n") )
msg += "\n"

root = Dir.pwd

home = ENV['HOME'] = Dir.mktmpdir

Dir.chdir home
puts `git clone "http://github.com/iron-io/iron_worker_ruby_ng.git" iwng`
Dir.chdir 'iwng'

FileUtils.cp(root + '/iron.json', '.')

bundler_path = home + '/bundler_gems'
Dir.mkdir bundler_path

puts `bundle install --path #{bundler_path}`
puts `bundle install --gemfile test/Gemfile --path #{bundler_path}`

gem_path = Dir.glob(bundler_path + '/*/*')
ENV['GEM_PATH'] = (gem_path + (ENV['GEM_PATH'] || '').split(':')).join(':')

run_tests = Proc.new do
  path = "test_log_#{ Time.now.strftime('%F_%H_%M') }.txt"

  fork { exec "rake -f test/Rakefile test >#{path} 2>&1" }
  Process.wait

  AWS::S3::Base.establish_connection! config[:aws]

  AWS::S3::S3Object.store(path, open(path), 'abt-ng-logs',
                          :access => :public_read)

  path
end

after = run_tests.call
puts `git checkout #{push['before']}`
before = run_tests.call

SUMMARY_R = %r/(\d+) tests, (\d+) assertions, (\d+) failures, (\d+) errors, (\d+) skips/

msg += "before: "
msg += "<a href=\"http://s3.amazonaws.com/abt-ng-logs/#{before}\">full log</a> "
if log = File.read(before) and log =~ SUMMARY_R
  msg += $&
end
msg += "\n"

msg += "after: "
msg += "<a href=\"http://s3.amazonaws.com/abt-ng-logs/#{after}\">full log</a> "
if log = File.read(after) and pos = log =~ /^Finished in/
  res = log[pos .. -1]
  if pos = res =~ SUMMARY_R
    msg += ' ' + $& + "\n"
    res = res[0 .. pos - 1]
  end
  msg += ' <pre>' + CGI::escapeHTML(res) + ' </pre>'
  msg = msg.gsub( %r|#{Dir.pwd}/(.*):(\d+)|,
                  '<a href="https://github.com/iron-io/iron_worker_ruby_ng/' +
                  'blob/' + push['after'] + '/\1#L\2">\0</a>' )
end

msg = msg.gsub(/\n+/,"<br>")

hipchat = HipChat::Client.new(config[:hipchat])
color = if msg =~ /0 failures, 0 errors, 0 skips/
          :green
        else
          :red
        end
hipchat["IronWorker"].send('NG test', msg,
                           :notify => false,
                           :color => color)
