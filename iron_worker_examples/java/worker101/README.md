# Worker 101

This covers most of the core concepts of using IronWorker including loading third party
dependencies.

1. Be sure you've setup your Iron.io credentials, see main [README.md](https://github.com/iron-io/iron_worker_examples).
1. Compile java file 'javac -cp "json-java.jar:gson-1.7.jar" Worker101.java'
1. Make jar file 'jar cfm worker101.jar manifest.txt Worker101.class'
1. Run `iron_worker upload worker101` to upload the worker code package to IronWorker.
1. Queue up a task:
  1. From command line: `iron_worker queue JavaWorker101 --payload '{"query":"xbox"}' --priority 2 --timeout 60`
  1. With enqueue.java - get latest iron_worker_java lib (https://github.com/iron-io/iron_worker_java), change query, compile it and launch.
1. Look at [HUD](https://hud.iron.io) to view your tasks running, check logs, etc.
1. Schedule a task:
  1. From command line: `iron_worker schedule JavaWorker101 --payload '{"query":"heyaa"}' --delay 5 --timeout 60 --start-at "12:30" --run-times 5 --run-every 70`

