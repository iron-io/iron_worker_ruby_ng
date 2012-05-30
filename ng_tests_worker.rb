Dir.chdir Dir.glob('iwng/*').first
ENV['NG_GEM_PATH'] = $:.join ':'
exec 'rake -f test/Rakefile test TESTP=basic'
