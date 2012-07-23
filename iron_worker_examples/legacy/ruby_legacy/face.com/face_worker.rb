require 'iron_worker'
require 'json'
require 'open-uri'
require 'rest-client'
class FaceWorker < IronWorker::Base
  merge_worker File.join("../email_worker/email_worker.rb"), "EmailWorker"
  attr_accessor :images_list, :api_key, :api_secret, :email_username, :email_password, :email_domain, :send_to, :title

  def run()
    msg            = "Recognition report\n"
    stats          = {}
    stats["person"]=0
    stats["male"]  =0
    stats["female"]=0
    images_list.each_index do |image_index|
      begin
        response = RestClient.get 'http://api.face.com/faces/detect.format', {:params => {:api_key => api_key, :api_secret => api_secret, :urls=>images_list[image_index]}}
        parsed   = JSON.parse(response)
        tags     = parsed["photos"][0]["tags"]
        tags.each do |tag|
          stats["person"]+=1
          stats[tag["attributes"]["gender"]["value"]]+=1 if tag["attributes"]["gender"]
        end
      rescue =>ex
        puts "EXCEPTION #{ex.inspect}"
      end
    end
    msg+=<<EOF
Total number of photos:    #{images_list.count.to_s}
Total number of persons found:    #{stats["person"].to_s}
Male/Female:    #{stats["male"].to_s}    /    #{stats["female"].to_s}
EOF
    send_mail(title, msg, send_to)
  end


  def send_mail(subject, body, to)
    email              = EmailWorker.new
    email.email_domain = email_domain
    email.username     = email_username
    email.password     = email_password
    email.from         = 'system@somewhere.com'
    email.to           = to
    email.subject      = "[Face] #{subject}"
    email.body         = body
    email.queue
  end

end