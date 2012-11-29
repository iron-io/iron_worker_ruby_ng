# Github Webhook Worker

This shows how to kick off a worker from a webhook. This example uses Github's Service Hooks.

1. Be sure you've setup your Iron.io credentials, see main [README.md](https://github.com/iron-io/iron_worker_examples).
1. Copy or rename the webhook_config_example.yml to webhook_config.yml and edit it to set your hipchat credentials.
1. `iron_worker upload github_webhook`
1. See webhook url `iron_worker webhook github_webhook`
1. Add it in github repo "WebHook URLs" list (admin page, "Service Hooks" section)
1. Click Update Settings
1. Click Test Hook
1. Check the worker status and logs in IronWorker at http://hud.iron.io to ensure it ran successfully.
1. Check HipChat for messages from webhook.

That's it, now everytime someone pushes to your github repo, it'll execute `github_webhook` worker on IronWorker.
