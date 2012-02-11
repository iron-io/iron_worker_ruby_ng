require 'digest/md5'

require_relative 'mergers/base_merger'
require_relative 'mergers/file_merger'
require_relative 'mergers/dir_merger'
require_relative 'mergers/gem_merger'
require_relative 'mergers/worker_merger'

module IronWorkerNG
  module Mergers
    module InstanceMethods
      attr_reader :merges

      @merges = []

      def hash_string
        Digest::MD5.hexdigest(@merges.map { |m| m.hash_string }.join)
      end

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
