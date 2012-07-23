
This is a sample worker that uses CarrierWave, RMagick, and ImageMagick to perform image manipulation using the [IronWorker service](http://www.iron.io).


## 1. Edit carrierwave.yml and fill in your IronWorker and AWS information.

- Make sure the bucket exists.
- You can find your IronWorker project_id and token by logging into [iron.io](http://www.iron.io) and creating a new project.
- The "Get Started" page will have your project_id and token.


## 2. Run "ruby carrierwave_worker_init.rb"

- This will upload our sample image to S3 so that our sample worker will have an image to work with
- It will then create a simple html page with a link to the uploaded image in S3.

## 3. Run "ruby carrierwave_worker_runner.rb".

This is the exciting part! Simply executing the runner will:
- Take the code in carrierwave_worker.rb, upload it to our servers and queue it in our system.

You can then immediately view the job running in your jobs tab at [iron.io](http://www.iron.io).

This particular sample should only take a few seconds to finish and then you can refresh the HTML page created in step 2 viewing the image that was modified in your worker.



### That's it!