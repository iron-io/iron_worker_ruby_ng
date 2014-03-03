require_relative '../helpers'
require 'rest'
require 'net/imap'

class ExampleActionMailerStandaloneTest < IWNGTest

  def test_example
    Dir.chdir 'examples/actionmailer_standalone' do
      assert(cli('upload', 'actionmailer_standalone') =~ /Upload successful/) 
      assert(cli('queue', 'actionmailer_standalone',
                 payload_file: 'actionmailer_config.json') =~
             /queued with id='(.*)'/)

      # wait for delivery
      client.tasks.wait_for($1)
      sleep 10

      config = JSON.parse(File.read('actionmailer_config.json'))['gmail']
      begin
        imap = Net::IMAP.new('imap.gmail.com',993,true)
        imap.login(config['username'], config['password'])
        imap.select('INBOX')
        ids = imap.search(['SUBJECT', 'Sample subject'])
        assert ids.size >= 1
        id = ids.last
        msg = imap.fetch(id, 'RFC822')
        assert msg[0].attr['RFC822'] =~ /message sent using IronWorker/
        imap.store(id, "+FLAGS", [:Deleted])
      ensure
        imap.logout
        imap.disconnect
      end
    end
  end

end
