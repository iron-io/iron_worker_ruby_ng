require_relative '../helpers'
require 'rest'

class ExampleChargifyToCampfireWebhookTest < IWNGTest

  def test_example
    Dir.chdir 'examples/chargify_to_campfire_webhook_worker' do
      assert(cli('upload', 'chargify_to_campfire') =~ /Upload successful/) 

      assert(cli('webhook', 'chargify_to_campfire') =~ /^\s*(https.*)$/)
      webhook = $1

      rest = Rest::Client::new
      resp = rest.post(webhook, body: "payload[chargify]=testing&id=6825503&event=test")
      assert_equal 200, resp.code

      task_id = JSON.parse(resp.body)['id']
      client.tasks.wait_for(task_id)

      assert client.tasks.log(task_id) =~ /^Done$/
    end
  end

end
