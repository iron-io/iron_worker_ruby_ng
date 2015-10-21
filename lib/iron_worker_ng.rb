puts 'This gem is deprecated. Please see this page  https://github.com/iron-io/iron_worker_ruby_ng/ for more information about new tools.'

begin
  require 'json'
rescue LoadError
  raise "Please install json gem"
end

if (not ''.respond_to?(:start_with?)) or (not ''.respond_to?(:end_with?))
  class ::String
    def start_with?(prefix)
      prefix = prefix.to_s
      self[0, prefix.length] == prefix
    end

    def end_with?(suffix)
      suffix = suffix.to_s
      self[-suffix.length, suffix.length] == suffix
    end
  end
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
