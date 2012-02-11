module IronWorkerNG
  module Mergers
    class DirMerger < IronWorkerNG::Mergers::BaseMerger
      attr_reader :path
      attr_reader :dest

      def initialize(path, dest)
        @path = File.expand_path(path)
        @dest = dest
      end

      def merge(zip)
        Dir.glob(@path + '/**/**') do |path|
          zip.add(@dest + '/' + File.basename(@path) + path[@path.length .. -1], path)
        end
      end

      def hash_string
        s = @path + @dest + File.mtime(@path).to_i.to_s

        Dir.glob(@path + '/**/**') do |path|
          s += path + File.mtime(path).to_i.to_s
        end

        Digest::MD5.hexdigest(s)
      end
    end

    module InstanceMethods
      def merge_dir(path, dest = '.')
        @merges ||= []
        @merges << IronWorkerNG::Mergers::DirMerger.new(path, dest)
      end
    end
  end
end
