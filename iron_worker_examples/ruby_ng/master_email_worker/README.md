# Master/slave email sender

This is more complex example that show what is the best way to send a tons of emails using IronWorker.
Command line tool reference could be found here - http://dev.iron.io/worker/reference/cli/

## Getting started

- Edit _config.yml (iw and email sections)
- Upload the worker by running 'iron_worker upload master_email_worker' in this directory
- Upload the worker by running 'iron_worker upload email_worker' in email_worker directory
- run 'master_email_sender.rb'

That's it, now you should receive 10 emails that was send by 2 separate tasks fired by single master worker.

