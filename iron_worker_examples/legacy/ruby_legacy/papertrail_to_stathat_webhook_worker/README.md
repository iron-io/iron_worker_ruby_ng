# Papertrail Alerts Webhook Worker

This shows how to kick off a worker from a webhook. This example uses Papertrail's Webhook Alerts
to post to Stathat.

## Getting started

- Copy or rename the webhook_config_example.yml to webhook_config.yml
- Modify the stathat info webhook_config.yml
- Upload the worker by running `upload.rb` in this directory
- Add the following url to Papertrail's Alerts under Webhook: `https://worker-aws-us-east-1.iron.io/2/projects/MY_PROJECT_ID/tasks/webhook?code_name=GithubWebhookWorker&oauth=MY_IRON_TOKEN`
- Click Update (and refresh)
- Click Test alert
- Check the worker status and logs in IronWorker at http://hud.iron.io to ensure it ran successfully.

That's it, now everytime a Papertrail alert goes off, it will execute this worker on IronWorker.


