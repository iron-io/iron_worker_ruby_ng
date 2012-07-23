# Download a File from the Web Directly into S3

This is an example that given a URL, it will take the contents of that URL and put it into s3.

Run enqueue.rb to try it out.

## Configuration

Config should contain:

```
aws:
    access_key: MY_ACCESS_KEY
    secret_key: MY_SECRET_KEY
    s3_bucket_name: MY_BUCKET
```

