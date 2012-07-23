

## Compile mono.cs to an exe.

Using mono, you would run:

    gmcs hello.cs

Or build using Microsoft tools.

## Upload Worker

The `hello_mono.worker` defines the worker and it's dependencies. For this example, the only dependency
is the hello.exe file so that's all that's in it. Use the iron_worker command line interface (CLI) to upload
the worker.

    iron_worker upload hello

## Now you can queue up tasks for it!

    iron_worker queue HelloMono -p '{"query":"xbox"}'

