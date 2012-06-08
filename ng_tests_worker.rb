Dir.chdir 'iwng'
cmd = 'rake -f test/Rakefile test ' + params[:args]
puts cmd
STDOUT.flush
exec cmd
