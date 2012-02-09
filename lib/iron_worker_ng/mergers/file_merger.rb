module IronWorkerNG
  module Mergers
    class FileMerger < IronWorkerNG::Mergers::BaseMerger
      attr_reader :path
      attr_reader :dest

      def initialize(path, dest)
        @path = File.expand_path(path)
        @dest = dest
      end

      def merge(zip)
        zip.add(@dest + '/' + File.basename(@path), @path)
      end
    end

    module InstanceMethods
      def merge_file(path, dest = '.')
        @merges ||= []
        @merges << IronWorkerNG::Mergers::FileMerger.new(path, dest)
      end
    end
  end
end
