puts '--------------CPU Info--------------'
puts `lscpu`

puts "\n\n--------------MEM Info--------------"
puts `free -m`

puts "\n\n--------------HDD Info--------------"
puts `df -m`
puts "\n\n"