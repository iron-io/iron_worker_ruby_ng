require 'iron_worker'

class FFmpegVideoEncoderWorker < IronWorker::Base

  merge 'frames/Frame0.gif'
  merge 'frames/Frame1.gif'
  merge 'frames/Frame2.gif'
  merge 'frames/Frame3.gif'
  merge 'frames/Frame4.gif'
  merge 'frames/Frame5.gif'
  merge 'frames/Frame6.gif'
  merge 'frames/Frame7.gif'
  merge 'frames/Frame8.gif'
  merge 'frames/Frame9.gif'
  merge 'frames/Frame10.gif'
  merge 'frames/Frame11.gif'
  merge 'frames/Frame12.gif'
  merge 'frames/Frame13.gif'

  attr_accessor :output_file_name

  def run
    log "\n\nStart encoding: #{Time.now.utc}\n"

    cmd = "ffmpeg -f image2 -i Frame%d.gif #{output_file_name} 2>&1"
    output = %x[ #{cmd} ]
    version = output.split(/\n/)[0]
    log "FFmpeg version: #{version}\n"

    if File::exists?(output_file_name)
      size = File.size(output_file_name)
      log "Output file size: #{(size/1024).round(1)} KB\n"
    else
      log "[WARN] Output file not found!\n"
      log "Operation log: #{output}\n"
    end

    # Uploading encoded video to Amazon S3 or any other storage

    log "Done encoding: #{Time.now.utc}\n\n"
  end


end