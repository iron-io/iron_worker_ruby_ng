require 'iron_worker'
require 'open-uri'
require 'RMagick'

class ImageProcessor < IronWorker::Base

  merge_gem 'aws'
  merge_gem 'subexec'
  merge_gem 'mini_magick'

  attr_accessor :aws_access, :aws_secret, :aws_s3_bucket_name
  attr_accessor :image_url

  def resize_image(filename, width=nil, height=nil, format='jpg')
    image = MiniMagick::Image.open(filename)
    original_width, original_height = image[:width], image[:height]
    width ||= original_width
    height ||= original_height
    output_filename = "#{filename}_thumbnail_#{width}_#{height}.#{format}"
    image.resize "#{width}x#{height}"
    image.format format
    image.write output_filename
    output_filename
  end

  def generate_thumb(filename, width=nil, height=nil, format='jpg')
    output_filename = "#{filename}_thumbnail_#{width}_#{height}.#{format}"
    image = MiniMagick::Image.open(filename)
    image.combine_options do |c|
      c.thumbnail "#{width}x#{height}"
      c.background 'white'
      c.extent "#{width}x#{height}"
      c.gravity "center"
    end
    image.format format
    image.write output_filename
    output_filename
  end

  def sketch_image(filename, format='jpg')
    output_filename = "#{filename}_sketch.#{format}"
    image = MiniMagick::Image.open(filename)
    image.combine_options do |c|
      c.edge "1"
      c.negate
      c.normalize
      c.colorspace "Gray"
      c.blur "0x.5"
    end
    image.format format
    image.write output_filename
    output_filename
  end

  def normalize_image(filename, format='jpg')
    output_filename = "#{filename}_normalized.#{format}"
    image = MiniMagick::Image.open(filename)
    image.normalize
    image.format format
    image.write output_filename
    output_filename
  end

  def charcoal_sketch_image(filename, format='jpg')
    output_filename = "#{filename}_charcoal_sketch.#{format}"
    image = MiniMagick::Image.open(filename)
    image.charcoal '1'
    image.format format
    image.write output_filename
    output_filename
  end

  def level_image(filename, black_point, white_point, gamma, format='jpg')
    output_filename = "#{filename}_level.#{format}"
    image = MiniMagick::Image.open(filename)
    image.level " #{black_point},#{white_point},#{gamma}"
    image.format format
    image.write output_filename
    output_filename
  end

  def tile_image(filename, num_tiles_height, num_tiles_width)
    file_list=[]
    image = MiniMagick::Image.open(filename)
    original_width, original_height = image[:width], image[:height]
    slice_height = original_height / num_tiles_height
    slice_width = original_width / num_tiles_width
    num_tiles_width.times do |slice_w|
      file_list[slice_w]=[]
      num_tiles_height.times do |slice_h|
        output_filename = "filename_#{slice_h}_#{slice_w}.jpg"
        image = MiniMagick::Image.open(filename)
        image.crop "#{slice_width}x#{slice_height}+#{slice_w*slice_width}+#{slice_h*slice_height}"
        image.write output_filename
        file_list[slice_w][slice_h] = output_filename
      end
    end
    file_list
  end

  def merge_images(col_num, row_num, file_list)
    output_filename = "merged_file.jpg"
    ilg = Magick::ImageList.new
    col_num.times { |x| il = Magick::ImageList.new
    row_num.times { |y| il.push(Magick::Image.read(file_list[x][y]).first)}
    ilg.push(il.append(true)) }
    ilg.append(false).write(output_filename)
    output_filename
  end

  def upload_file(filename)
    filepath = user_dir + filename
    log "\nUploading the file to s3..."
    s3 = Aws::S3Interface.new(@aws_access, @aws_secret)
    s3.create_bucket(@aws_s3_bucket_name)
    response = s3.put(@aws_s3_bucket_name, filename, File.open(filepath))
    if (response == true)
      log "Uploading succesful."
      link = s3.get_link(@aws_s3_bucket_name, filename)
      log "\nYou can view the file here on s3:\n" + link
    else
      log "Error placing the file in s3."
    end
    log "-"*60
  end

  def download_image
    filename = 'ironman.jpg'
    filepath = user_dir + filename
    File.open(filepath, 'wb') do |fo|
      fo.write open(@image_url).read
    end
    filename
  end

  def run

    log "Downloading image"

    filename = download_image()

    log "Generating square thumbnail"
    processed_filename = generate_thumb(filename, 50, 50)
    upload_file(processed_filename)

    log "Generating small picture"
    processed_filename = resize_image(filename, nil, 100)
    upload_file(processed_filename)

    log "Generating normal picture"
    processed_filename = resize_image(filename, nil, 200)
    upload_file(processed_filename)

    log "Generating picture with tuned levels"
    processed_filename = level_image(filename, 10, 250, 1.0)
    upload_file(processed_filename)

    log "Tune picture"
    processed_filename = normalize_image(filename)
    upload_file(processed_filename)

    log "Generating sketch from picture"
    processed_filename = sketch_image(filename)
    upload_file(processed_filename)

    log "Generating charcoal_sketch from picture"
    processed_filename = charcoal_sketch_image(filename)
    upload_file(processed_filename)

    log "Cutting image to 6 puzzles 3x3"
    file_list = tile_image(filename, 3, 3)

    log "List of images ready to process,merging in one image"
    processed_filename = merge_images(3, 3, file_list)
    upload_file(processed_filename)
  end


end