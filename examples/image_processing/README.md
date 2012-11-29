Image Processing in Ruby with IronWorker
================================

This is the code that goes with this article: http://dev.iron.io/solutions/image-processing/

To run this example:

1. [Setup your Iron.io credentials](http://dev.iron.io/articles/configuration/) if you haven't done so already.
1. Install required gems:
  1. `sudo gem install subexec mini_magick aws`
1. From this directory, run: `iron_worker upload image_processor`
1. Copy the config_example.yml to config.yml and fill it in with your aws credentials
1. Run `ruby enqueue.rb`

Now go check hud, https://hud.iron.io , find the task and view the log to get the URL's for
all your images.
