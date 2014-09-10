available = `df -m  2>&1 | head -n 2 | tail -n 1 | awk '{print $2}'`

if available.to_i < 9500
  puts "Current available size (#{available}) is not as expected"
  abort
end

#should be >9500 && <10000
