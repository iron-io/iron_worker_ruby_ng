# Github Webhook Worker

This shows how to kick off a worker from a webhook. This example uses Github's Service Hooks.

## Getting started

- Copy or rename the webhook_config_example.yml to webhook_config.yml and edit it to set your hipchat credentials.
- Upload the worker by running `upload.rb` in this directory and follow instruction it prints
- Click Update Settings
- Click Test Hook
- Check the worker status and logs in IronWorker at http://hud.iron.io to ensure it ran successfully.

That's it, now everytime someone pushes to your github repo, it'll execute the GithubWebhookWorker on IronWorker.
