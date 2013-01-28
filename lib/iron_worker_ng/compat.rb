require 'tmpdir'
require 'fileutils'

unless Dir.const_defined?(:Tmpname)
  class Dir
    class Tmpname
      def self.make_tmpname(x, y)
        n = ::Dir.mktmpdir(x + y)
	FileUtils.rm_rf(n)

	n.sub(::Dir.tmpdir, '')
      end
    end
  end
end

