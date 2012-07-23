# Github Webhook Worker

This shows how to kick off a worker from a webhook. This example uses Github's Service Hooks.

## Getting started

- Copy or rename the webhook_config_example.yml to webhook_config.yml
- Modify the hipchat info in webhook_config.yml
- Upload the worker by running `upload.rb` in this directory
- Add the following url to github Service Hooks, Post-Receive URLs: `https://worker-aws-us-east-1.iron.io/2/projects/MY_PROJECT_ID/tasks/webhook?code_name=GithubWebhookWorker&oauth=MY_IRON_TOKEN`
- Click Update Settings
- Click Test Hook
- Check the worker status and logs in IronWorker at http://hud.iron.io to ensure it ran successfully.

That's it, now everytime someone pushes to your github repo, it'll execute the GithubWebhookWorker on IronWorker.

