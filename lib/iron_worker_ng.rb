begin
  require 'json'
rescue LoadError
  raise "Please install json gem"
end

require 'iron_worker_ng/version'
require 'iron_worker_ng/compat'
require 'iron_worker_ng/fetcher'
require 'iron_worker_ng/client'
require 'iron_worker_ng/code/base'
require 'iron_worker_ng/code/ruby'
require 'iron_worker_ng/code/binary'
require 'iron_worker_ng/code/java'
require 'iron_worker_ng/code/node'
require 'iron_worker_ng/code/mono'
require 'iron_worker_ng/code/python'
require 'iron_worker_ng/code/php'
require 'iron_worker_ng/code/go'
require 'iron_worker_ng/code/perl'
require 'iron_worker_ng/code/builder'
