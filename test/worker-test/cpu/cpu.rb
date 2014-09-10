loop_t1_finished = false

def pi_calc(den_len)
	num = 4.0
	pi = 0
	plus = true
	
	den = 1
	while den < den_len
	  if plus
	    pi = pi + num/den
	    plus = false
	  else
	    pi = pi - num/den
	    plus = true
	  end
	  den = den + 2
	end
	pi 
end

t1=Thread.new{pi=pi_calc(25000000); puts "PI = #{pi}"; loop_t1_finished = true;}

count=0
t2 = Thread.new do
    loop do
        count += 1
	Thread.exit if loop_t1_finished
	puts `ps aux | awk {'sum+=$3;print sum'} | tail -n 1`
        sleep(1)
    end
end

t2.join
puts "execution time =  #{count}"

if count > 5
  puts "Current execution time (#{count}) is not as expected"
  abort
end
#execution time < 5sec
