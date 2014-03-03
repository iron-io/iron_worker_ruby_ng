require_relative '../helpers'
require 'rest'
require 'iron_cache'
require 'net/imap'
require 'tempfile'

class ExampleEmailWorkerTest < IWNGTest

  def test_example
    Dir.chdir 'examples/email_worker' do
      assert(cli('upload', 'email_worker') =~ /Upload successful/)

      cfg = JSON.parse(File.read('email_config.json'))

      cache = IronCache::Client.new
      cache.items.delete(cfg['to']) if cache.items.get(cfg['to'])

      cfg['iron'] = { token: client.api.token,
                      project_id: client.api.project_id }
      tmp = Tempfile.new(['email_config', '.json'])
      tmp.write cfg.to_json
      tmp.close

      assert(cli('queue', 'email_worker',
                 payload_file: tmp.path) =~
             /queued with id='(.*)'/)

      # wait for delivery
      client.tasks.wait_for($1)
      sleep 10

      begin
        imap = Net::IMAP.new('imap.gmail.com',993,true)
        imap.login(cfg['smtp']['user_name'], cfg['smtp']['password'])
        imap.select('INBOX')
        ids = imap.search(['SUBJECT', 'hello from IronWorker'])
        assert ids.size >= 1
        id = ids.last
        msg = imap.fetch(id, 'RFC822')
        assert msg[0].attr['RFC822'] =~ /hello me/
        imap.store(id, "+FLAGS", [:Deleted])
      ensure
        imap.logout
        imap.disconnect
      end

      cache = IronCache::Client.new
      assert cache.items.get(cfg['to']).value =~ /hello me/

      tmp.unlink
    end
  end

end
