require 'iron_worker_ng/mergers/base_merger'
require 'iron_worker_ng/mergers/file_merger'
require 'iron_worker_ng/mergers/dir_merger'
require 'iron_worker_ng/mergers/gem_merger'
require 'iron_worker_ng/mergers/worker_merger'

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
