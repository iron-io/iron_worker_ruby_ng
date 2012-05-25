require 'tmpdir'

ENV['HOME'] = Dir.mktmpdir
ENV['GEM_HOME'] = Dir.mktmpdir

Dir.chdir Dir.glob('iwng/*').first

puts `gem install rake`
puts `gem install git`

puts `cat test/Gemfile >> Gemfile`

puts `bundle install`

`rake -f test/Rakefile test TESTP=basic`
