This example will check twitter for search keywords and post to a Hipchat chat room. You can schedule it
to run recurring if you want get regular tweets to your Hipchat room (see queue.rb for examples).

Update the config.yml and simply queue or schedule the worker by running enqueue.rb.

You can setup API tokens for Hipchat in the Hipchat Group Admin section. Click API tokens and create one.
Twitter search doesn't require authentication (thankfully because it's much more complicated to
get a token) so no setup required there.

