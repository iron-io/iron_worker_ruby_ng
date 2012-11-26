require 'active_support/core_ext'
require 'hipchat-api'
require 'google_drive'
require 'oauth2'
require 'time'

####################
#PARAMS
puts params.inspect
hipchat_token = params["hipchat_token"]
exclude_rooms = params["exclude_rooms"] || []
# Need either google username and pass or an oauth2 token
google_user = params["google_username"]
google_pass = params["google_password"]
# OR
google_client_id = params["google_client_id"]
google_secret = params["google_secret"]
google_refresh_token = params["google_refresh_token"]
range_ago = params["range_ago"]
###################


range_ago||=1
if google_refresh_token
  client = OAuth2::Client.new(
      google_client_id,
      google_secret,
      :site => "https://accounts.google.com",
      :token_url => "/o/oauth2/token",
      :authorize_url => "/o/oauth2/auth")
  access_token = OAuth2::AccessToken.from_hash(client, {:refresh_token => google_refresh_token})
  access_token = access_token.refresh!
  session = GoogleDrive.login_with_oauth(access_token)
else
  session = GoogleDrive.login(google_user, google_pass)
end
hipchat = HipChat::API.new(hipchat_token)
end_date = Time.now
start_date = end_date - range_ago.month
rooms = hipchat.rooms_list
#p rooms
puts "Found #{rooms.size} rooms"
open_rooms = rooms.to_hash["rooms"].select { |r| !r["is_private"] }
rooms_history = {}

filename = "HipChat Archive - #{Time.now.strftime('%Y-%m')}"
file = session.files("title" => filename)

puts "Looking for file: #{filename}"
if file.empty?
  puts "File not found, creating new one!"
  file = session.create_spreadsheet(filename)
else
  puts "File found, let's use it"
  file = file.first
end


open_rooms.each do |room|
  room_name = room["name"]
  puts "Room: #{room_name} - private? #{room["is_private"]}"
  puts "Looking for a worksheet: #{room_name}"
  if exclude_rooms.include?(room_name)
    puts "Skipping room."
    next
  end
  ws = file.worksheet_by_title(room_name)
  import_from = Time.at(room["created"])
  if ws
    puts "Worksheet found!"
    last_entry = ws.list.entries.last
    if last_entry
      last_date = last_entry["date"]
      puts "Last date used: #{last_date}"
      # eg: Last date used: 7/3/2012 0:19:22
      if last_date.length < 12
        import_from = Date.strptime(last_date, "%m/%d/%Y").to_time
      else
        import_from = DateTime.strptime(last_date, "%m/%d/%Y %H:%M:%S")
      end
    end
    puts "import_from: #{import_from}"
  else
    puts "No such worksheet, creating new"
    ws = file.add_worksheet(room_name)
    ws.list.keys = ["date", "from", "message"]
    ws.save
  end
  import_from = start_date if start_date > import_from
  puts "Latest timestamp :#{import_from}"
  days_back = ((end_date - import_from)/60/60/24).ceil
  puts "Should look for #{days_back} days back"
  days_back.downto(0) do |i|
    date_to_get = (end_date - i.days)
    formatted_date = date_to_get.strftime('%Y-%m-%d')
    puts "Getting messages #{i} days ago - #{formatted_date}"
    resp = hipchat.rooms_history(room_name, formatted_date, 'UTC').parsed_response
    messages = rooms_history[room_name]= resp["messages"]
    #puts "Found messages:#{messages.inspect}"
    if !messages
      # something is wrong
      puts "NO MESSAGES!"
      p resp
      break
    elsif messages.size > 0
      messages.each_with_index do |m, i|
        d = DateTime.parse(m["date"])
        next if d <= import_from
        puts "Pushing message :#{m.inspect}"
        ws.list.push({:date => d.strftime("%m/%d/%Y %H:%M:%S"), :from => m["from"]["name"], :message => m["message"]})
        ws.save if i % 50 == 0
      end
      ws.save
    else
      ws.list.push({:date => date_to_get.strftime('%Y-%m-%d'), :from => "--", :message => "No messages"})
      ws.save
    end
  end
end

temp_sheet = file.worksheet_by_title('Sheet 1')
temp_sheet.delete if temp_sheet
