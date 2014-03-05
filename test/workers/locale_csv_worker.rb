require 'csv'
t  = ""
CSV.foreach( "file.csv") do |row|
t+=row.join('-')
end
puts "All good"
