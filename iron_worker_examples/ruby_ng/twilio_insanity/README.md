
Setup:

1. Sign up for free accounts at Twilio.com and Iron.io
2. git clone https://github.com/iron-io/iron_worker_examples.git
3. cd ruby_ng/twilio_insanity
4. sudo bundle install (iron_worker_ng has the iron_worker command line interface)
5. fill in values in config/config.yml file
6. fill in values in workers/iron.json
7. cd workers
8. iron_worker upload send_insanity
9. iron_worker upload twilio_webhook
10. go to Twilio.com and in the SMS URL enter URL below (fill in your values) and make sure it's set to POST


To Run:

1. return to twilio_insanity directory
2. ruby web.rb
3. browse to http://localhost:4567/
4. enter your number click "Let's get Insane!"


Checking that things worked:

- two uploaded code packages: SendInsanity and TwilioWebhook
- one scheduled task
- You'll get your first SMS
- Go to IronCache and you'll see the cache created
- Respond to the SMS with "done" to move the day forward


NOTE: If you're using a free Twilio account, you'll need to preface all SMS's with your "Sandbox Pin"
Your response will look like this: "1234-5678 done"


https://worker-aws-us-east-1.iron.io/2/projects/{PROJECT_ID}/tasks/webhook?code_name=TwilioWebhook&oauth={TOKEN}
