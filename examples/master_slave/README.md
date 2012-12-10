# master-slave example

This example shows how to run worker from other worker.

1. Be sure you've setup your Iron.io credentials, see main [README.md](https://github.com/iron-io/iron_worker_examples).
2. Run `iron_worker upload master` to upload master worker.
2. Run `iron_worker upload slave` to upload slave worker.
3. Run `ruby enqueue.rb` to queue up a task.
4. Look at [HUD](https://hud.iron.io) to view your tasks running, check logs, etc.

Read the code in this directory to learn more about what happened.
