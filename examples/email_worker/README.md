# email_worker example

This is simple example how to send email using IronWorker

1. Be sure you've setup your Iron.io credentials, see main [README.md](https://github.com/iron-io/iron_worker_examples).
2. Copy  `email_config_sample.json` to `email_config.json` and edit it to set your credentials.
3. Run `iron_worker upload email_worker` to upload worker.
4. Run `iron_worker queue email_worker --payload-file email_config.json`
5. Look at [HUD](https://hud.iron.io) to view your tasks running, check logs, etc.

That's it, now you should receive email.
Read the code in this directory to learn more about what happened.