require 'rubygems'
require 'bundler'

task :test do
  # running separate rake process to avoid bundler setup clash
  sh "cd test && rake #{$*.join(' ')}"
end
