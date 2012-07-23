require 'iron_worker'
require 'open-uri'

class S3Worker < IronWorker::Base

  merge_gem 'aws'

  attr_accessor :aws_access, :aws_secret, :aws_s3_bucket_name
  attr_accessor :image_url

  def run
    log "\nRunning s3_Worker..."
    log "Local 'user_dir' storage before:"
    user_files = %x[ls #{user_dir.inspect}]
    log "#{user_files}"

    if is_remote?
      log "\nDownloading file to local worker disk storage in IronWorker..."
    else
      log "\nDownloading file to local disk storage..."
    end
     
    filename = 'ironman.jpg'
    filepath = user_dir + filename
    File.open(filepath, 'wb') do |fo|
      fo.write open(@image_url).read
    end

    log "\nLocal 'user_dir' storage after:"
    user_files = %x[ls #{user_dir.inspect}]
    log "#{user_files}"
    
    log "\nUploading the file to s3..."
    s3 = Aws::S3Interface.new(@aws_access, @aws_secret)
    s3.create_bucket(@aws_s3_bucket_name)
    response = s3.put(@aws_s3_bucket_name, filename, File.open(filepath))

    if (response == true)
      log "Uploading successful."
      link = s3.get_link(@aws_s3_bucket_name, filename)
      log "\nYou can view the file here on s3:\n" + link
    else
      log "Error placing the file in s3."
    end
    

    #log "Getting file from s3..."
    #sdb = Aws::SdbInterface.new(@aws_access, @aws_secret)
    #log "All OK!\nGetting domains..."
    #sdb.list_domains[:domains].each{|x| log x.inspect }
    log "\nFinished processing s3_Worker.\n"
  end
end

