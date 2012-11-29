This example shows you how to send and schedule SMS messages with Twilio via IronWorker. IronWorker for scheduling and Twilio
for sending the SMS's. Using IronWorker not only gives you scheduling capabilities, but also allows you to do some
pre-processing before hand to generate custom messages for each of your users and you can parallelize all that work
without any extra effort.

There are two common scenarios:

1. you want to schedule a single SMS to go out at some point in the future.
1. you want to schedule a recurring task that will send SMS's out on some recurring schedule, like nightly for example.

We'll cover both of these. But first, our sms worker, take a look `sms.rb`. This worker simply sends an sms via Twilio.

## Getting Started

- first, you must have an [Iron.io](http://www.iron.io) account
- and have your iron.json file setup. See: http://dev.iron.io/articles/configuration/
- copy `config_example.yml` to `config.yml` and fill it in, with your Twilio information. In the 'to' field,
enter your own mobile phone number so you can receive the text.

## Sending a Text

- upload the worker if it hasn't been uploaded yet, from command line: `iron_worker upload sms`
- now run `ruby enqueue_sms.rb` which will queue up an sms task
- you should get a text in a few seconds.

Take a look at enqueue_sms.rb for the code that queues up the task and hud.iron.io for the log and task status.

## Sending a text in the future

- upload the worker if it hasn't been uploaded yet, from command line: `iron_worker upload sms`
- now run `ruby enqueue_sms.rb 60` which will queue up an sms task that will run in 60 seconds
- you should get a text in 60 seconds.

Take a look at enqueue_sms.rb for the code that queues up the task and hud.iron.io for the log and task status.

## Scheduling nightly batch notifications

- from command line: `iron_worker upload sms_all_users`
- now run: `ruby schedule_sms_all_users.rb`
- you should get a text in right away, then another in 1 minute.
- look at the Scheduled Tasks tab at http://hud.iron.io to see the schedule.

Take a look at schedules_sms_all_users.rb for the code that schedules the task and hud.iron.io for the log and task status.

