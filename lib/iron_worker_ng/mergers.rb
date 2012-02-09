require_relative 'mergers/base_merger'
require_relative 'mergers/file_merger'
require_relative 'mergers/dir_merger'
require_relative 'mergers/gem_merger'
require_relative 'mergers/worker_merger'

module IronWorkerNG
  module Mergers
    module InstanceMethods
      @merges = []

      def execute_merge(zip)
        init_code = ''

        @merges.each do |merge|
          merge.merge(zip)

          merge_init_code = merge.init_code
          init_code += merge_init_code + "\n" unless merge_init_code.nil?
        end

        init_code
      end
    end
  end
end
