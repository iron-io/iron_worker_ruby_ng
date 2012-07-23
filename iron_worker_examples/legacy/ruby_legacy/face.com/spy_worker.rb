require 'iron_worker'
require 'json'
require 'open-uri'
require 'rest-client'
require 'rss'
class SpyWorker < IronWorker::Base
  merge_worker File.join("../email_worker/email_worker.rb"), "EmailWorker"
  attr_accessor :rss_feed, :api_key, :api_secret, :email_username, :email_password, :email_domain, :send_to, :title, :last_date

  def get_new_images()
    images_list = []
    rss         = RSS::Parser.parse(open(rss_feed).read, false)
    rss.items.each do |item|
      next if item.date<Time.parse(last_date)
      url = item.link
      id  = url.scan(/http:\/\/twitpic\.com\/(\w+)/)
      images_list<<"http://twitpic.com/show/thumb/" + id[0][0] if id
    end
    self.last_date = rss.items.first.date
    images_list
  end

  def run()
    require 'active_support/core_ext'
    msg         = "New Face found!\n"
    found       =false
    images_list = get_new_images()
    log "IMAGES LIST#{images_list.inspect}"
    images_list.each_index do |image_index|
      begin
        response = RestClient.get 'http://api.face.com/faces/detect.format', {:params => {:api_key => api_key, :api_secret => api_secret, :urls=>images_list[image_index]}}
        parsed   = JSON.parse(response)
        tags     = parsed["photos"][0]["tags"]
        if tags.size >0
          found = true
          msg   +="\nLink to image with face #{images_list[image_index]}"
        end
      rescue =>ex
        puts "EXCEPTION #{ex.inspect}"
      end
    end
    send_mail(title, msg, send_to) if found

    log "last_date -" + self.last_date.to_s
    worker = self.dup
    worker.schedule(:start_at=>1.hours.since)
  end


  def send_mail(subject, body, to)
    email              = EmailWorker.new
    email.email_domain = email_domain
    email.username     = email_username
    email.password     = email_password
    email.from         = 'system@simpledeployer.com'
    email.to           = to
    email.subject      = "[Face] #{subject}"
    email.body         = body
    email.queue
  end

end