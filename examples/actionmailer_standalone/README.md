# action_mailer example

This example shows how to send emails in worker.

1. Be sure you've setup your Iron.io credentials, see main [README.md](https://github.com/iron-io/iron_worker_examples).
2. Copy  `actionmailer_config_sample.json` to `actionmailer_config.json` and edit it to set your gmail credentials.
3. Run `iron_worker upload actionmailer_standalone` to upload worker.
4. Run `iron_worker queue actionmailer_standalone --payload-file actionmailer_config.json`
5. Look at [HUD](https://hud.iron.io) to view your tasks running, check logs, etc.

Read the code in this directory to learn more about what happened.
