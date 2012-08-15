# Worker 101

This covers most of the core concepts of using IronWorker including loading third party
dependencies.

1. Be sure you've setup your Iron.io credentials, see main [README.md](https://github.com/iron-io/iron_worker_examples).
1. Compile your worker 'gmcs worker101.cs' or if you see message that Script doesn't exist then use 'gmcs  -r:System.Web.Extensions.dll worker101.cs '
1. Run `iron_worker upload worker101` to upload the worker code package to IronWorker.
1. Queue up a task:
  1. From command line: `iron_worker queue MonoWorker101 --payload '{"query":"xbox"}' --priority 2 --timeout 60`
  1. From code: set your token and project_id,compile and run enqueue.cs: `gmcs enqueue.cs;mono enqueue.exe`
1. Look at [HUD](https://hud.iron.io) to view your tasks running, check logs, etc.
1. Schedule a task:
  1. From command line: `iron_worker schedule MonoWorker101 --payload '{"query":"heyaa"}' --delay 5 --timeout 60 --start-at "12:30" --run-times 5 --run-every 70`