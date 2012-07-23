require 'iron_worker'
require 'json'
require 'open-uri'
require 'rest-client'
require 'yaml'

def get_images_twitpic(username)
  json         = open('http://api.twitpic.com/2/users/show.json?username='+username).read
  images       = JSON.parse(json)
  total_images = images["photo_count"]
  images_list  =[]
  if total_images && total_images.to_i >0
    total_pages = (total_images.to_f/20).ceil
    1.upto(total_pages) do |page|
      json   = open('http://api.twitpic.com/2/users/show.json?username='+username+'&page=' + page.to_s).read
      images = JSON.parse(json)
      images["images"].each do |image|
        images_list << "http://twitpic.com/show/thumb/" + image["short_id"]
      end
    end
  end
  images_list
end

SETTINGS = YAML.load_file('../_config.yml')

IronWorker.configure do |config|
  config.token = SETTINGS["iw"]["token"]
  config.project_id = SETTINGS["iw"]["project_id"]
end

load "face_worker.rb"
tw_username       = "Twilight"
fw                = FaceWorker.new
fw.images_list    = get_images_twitpic(tw_username)
fw.api_key        = SETTINGS["face"]["api_key"]
fw.api_secret     = SETTINGS["face"]["api_secret"]
fw.email_username = SETTINGS["email"]["username"]
fw.email_password = SETTINGS["email"]["password"]
fw.email_domain   = SETTINGS["email"]["domain"]
fw.send_to        = "user@email.com"
fw.title          = "Twitpic account #{tw_username}"
fw.queue