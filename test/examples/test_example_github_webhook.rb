require_relative '../helpers'
require 'rest'

class ExampleGithubWebhookTest < IWNGTest

  def test_example
    Dir.chdir 'examples/github_to_hipchat_webhook_worker' do
      assert(cli('upload', 'github_webhook') =~ /Upload successful/) 

      assert(cli('webhook', 'github_webhook') =~ /^\s*(https.*)$/)
      webhook = $1

      rest = Rest::Client::new
      resp = rest.post(webhook, body: File.read('sample_github_payload'))
      assert_equal 200, resp.code

      task_id = JSON.parse(resp.body)['id']
      client.tasks.wait_for(task_id)

      assert client.tasks.log(task_id) =~ /^Done$/
    end
  end

end
