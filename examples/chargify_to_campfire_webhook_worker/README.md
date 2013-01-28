# Chargify Webhook Worker

This shows how to kick off a worker from a webhook. This example uses Chargify's webhooks.

1. Be sure you've setup your Iron.io credentials, see main [README.md](https://github.com/iron-io/iron_worker_examples).
1. Copy or rename the campfire_config_example.json to campfire_config.json and edit it to set your campfire credentials.
1. `iron_worker upload chargify_to_campfire`
1. See webhook url `iron_worker webhook chargify_to_campfire`
1. Set it in chargify (Settings -> Webhooks)
1. Select types of events you want to be notified of.
1. Click 'Save Webhook settings'
1. Click 'Send a test Webhook'
1. Check the worker status and logs in IronWorker at http://hud.iron.io to ensure it ran successfully.
1. Check campfire for messages from webhook.

That's it, now you'll be notified about selected chargify events in campfire.
