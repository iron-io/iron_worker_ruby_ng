require 'hipchat'
require 'aws/s3'
require 'tmpdir'
require 'json'

config = JSON.parse( File.read('.abt-ng-config'),
                     :symbolize_names => true )

Dir.chdir Dir.tmpdir

puts `git clone "http://github.com/iron-io/iron_worker_ruby_ng.git" iwng`

Dir.chdir('iwng')

path = "test_log_#{ Time.now.strftime('%F_%H_%M') }.txt"

fork { exec "rake -f test/Rakefile test >#{path} 2>&1" }
Process.wait

AWS::S3::Base.establish_connection! config[:aws]

AWS::S3::S3Object.store(path, open(path), 'abt-ng-logs',
                        :access => :public_read)

msg = "<a href=\"http://s3.amazonaws.com/abt-ng-logs/#{path}\">Full log</a>"
if log = File.read(path) and pos = log =~ /Finished tests in.*/
  msg += ' <pre>' + log[pos..-1].gsub(/\n+/,"<br>") + ' </pre>'
end

hipchat = HipChat::Client.new(config[:hipchat])
hipchat["Test"].send('NG test', msg,
                     :notify => false,
                     :color => if msg =~ /0 failures, 0 errors, 0 skips/
                                 :green
                               else
                                 :red
                               end)
