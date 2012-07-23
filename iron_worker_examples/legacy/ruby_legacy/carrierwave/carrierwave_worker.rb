require 'iron_worker'

class CarrierWaveWorker < IronWorker::Base
  require 'RMagick' # it's available at IronWorker servers

  merge_gem 'carrierwave'
                    # if you need ActiveRecord support, use following line instead
                    # merge_gem 'carrierwave', :require => ['carrierwave', 'carrierwave/orm/activerecord']

  merge_gem 'fog'

  merge 'sample_uploader'
  merge 'carrierwave_configure'

  attr_accessor :aws_access_key
  attr_accessor :aws_secret_key
  attr_accessor :aws_bucket
  attr_accessor :image_file

  def run
    carrierwave_configure(@aws_access_key, @aws_secret_key, @aws_bucket)

    uploader = SampleUploader.new
    uploader.retrieve_from_store!(image_file)
    uploader.cache_stored_file!

    i = Magick::ImageList.new(uploader.file.path)

    i1 = i.resize_to_fit(150)
    i2 = i.sketch
    i3 = i.rotate(90)

    i1.write("processed-1.png")
    i2.write("processed-2.png")
    i3.write("processed-3.png")

    uploader.store!(File.new("processed-1.png"))
    uploader.store!(File.new("processed-2.png"))
    uploader.store!(File.new("processed-3.png"))
  end


end
