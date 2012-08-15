# Hello Mono Worker!

This is one of the simplest workers you can run:

1. Be sure you've setup your Iron.io credentials, see main [README.md](https://github.com/iron-io/iron_worker_examples).
1. Compile your worker using Microsoft Visual Studio
  1. or if you're using mono: `gmcs hello.cs` or if you see message that Script doesn't exist then use `gmcs  -r:System.Web.Extensions.dll hello.cs`
1. Run `iron_worker upload hello` to upload the worker code package to IronWorker. This reads the `hello.worker` file to build the package. .worker files define the worker dependencies.
1. Queue up a task:
  1. From command line: `iron_worker queue hello --payload '{"query":"xbox"}'`
  1. From code: Open `enqueue.cs` and edit it to set your token and project_id. Then compile and run it (mono users: `gmcs enqueue.cs; mono enqueue.exe`).
1. Look at [HUD](https://hud.iron.io) to view your tasks running, check logs, etc.
1. Schedule a task:
  1. From command line: `iron_worker schedule hello --payload '{"query":"heyaa"}' --delay 5 --timeout 60 --start-at "12:30" --run-times 5 --run-every 70`
