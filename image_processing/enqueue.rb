require 'yaml'
require 'iron_worker_ng'

# Create an IronWorker client
config_data = YAML.load_file 'config.yml'
client = IronWorkerNG::Client.new()

aws = config_data['aws']
client.tasks.create(
    'ImageProcessor',
    image_url: config_data['image_url'],
    aws_access: aws['access_key'],
    aws_secret: aws['secret_key'],
    aws_s3_bucket_name: aws['s3_bucket_name'],
)
