This example kicks off a number of Pusher clients, ClientWorker, that listen on a pusher channel for messages.
It also kicks off a single ServerWorker that will broadcast a message to all the ClientWorker's and
when a ClientWorker receives a message with it's own id, it will terminate.
