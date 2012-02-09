module IronWorkerNG
  module Mergers
    class DirMerger < IronWorkerNG::Mergers::BaseMerger
      def initialize(path, dest)
        @path = File.expand_path(path)
        @dest = dest
      end

      def merge(zip)
        Dir.glob(@path + '/**/**') do |path|
          zip.add(@dest + '/' + File.basename(@path) + path[@path.length .. -1], path)
        end
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
