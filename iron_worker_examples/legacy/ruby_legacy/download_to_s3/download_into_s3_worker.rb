require 'iron_worker'
require 'open-uri'

class DownloadIntoS3Worker < IronWorker::Base

  merge_gem 'aws'

  attr_accessor :config,
                :url, # url to suck into s3
                :s3_key

  def run
    filepath = user_dir + s3_key

    # This is probably a bit naive, I'm sure with some thought the file could be directly piped into s3.
    puts "Writing file to #{filepath}..."
    File.open(filepath, 'wb') do |fo|
      fo.write open(url).read
    end

    s3 = Aws::S3Interface.new(config['aws']['access_key'], config['aws']['secret_key'])

    bucket_name = config['aws']['s3_bucket_name']
    puts "Creating bucket..."
    s3.create_bucket(bucket_name)
    puts "Uploading the file to s3..."
    response = s3.put(bucket_name, s3_key, File.open(filepath))
    p response

    if (response == true)
      puts "Upload successful."
      link = s3.get_link(bucket_name, s3_key)
      puts "\nYou can view the file here on s3:\n" + link
    else
      puts "Error placing the file in s3."
    end


  end

end
