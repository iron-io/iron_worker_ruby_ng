This example uses IronWorker's 'delay' feature to limit the rate at which tasks will be executed. It
queues up up a bunch of tasks with increasing delay. The task in this example will post to a HipChat
room every 30 seconds.

See enqueue.rb to see how the delay parameter is used.
