module IronWorkerNG
  module Mergers
    class WorkerMerger < IronWorkerNG::Mergers::BaseMerger
      attr_reader :path
      attr_reader :name

      def initialize(path, name)
        @path = File.expand_path(path)
        @name = name
      end

      def merge(zip)
        zip.add('./' + File.basename(@path), @path)
      end
    end

    module InstanceMethods
      def merge_worker(path, name, force_main = false)
        @merges ||= []
        @merges << IronWorkerNG::Mergers::WorkerMerger.new(path, name)

        @main_worker = @merges[-1] if @main_worker.nil? || force_main
      end
    end
  end
end
