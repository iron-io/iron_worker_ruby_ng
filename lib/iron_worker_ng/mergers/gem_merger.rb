require 'iron_worker_ng/simple_gem'

module IronWorkerNG
  module Mergers
    class GemMerger < IronWorkerNG::Mergers::BaseMerger
      attr_reader :gem

      def initialize(gem)
        @gem = gem
      end

      def merge(zip)
        zip.add('./merged_gems/' + @gem.to_s, @gem.path)
        Dir.glob(@gem.path + '/**/**') do |path|
          zip.add('./merged_gems/' + @gem.to_s + path[@gem.path.length .. -1], path)
        end
      end

      def init_code
        '$:.unshift("#{root}/merged_gems/' + @gem.to_s + '/lib")'
      end
    end

    module InstanceMethods
      def merge_gem(name, version = nil)
        @merges ||= []
        @merged_gems ||= []

        blacklist = ['tzinfo']

        gem = IronWorkerNG::SimpleGem.find(name, version)[-1]

        return if gem.nil?
        return if gem.native?
        return if @merged_gems.include?(gem)
        return if blacklist.include?(gem.name)

        deps = gem.deps(true)

        deps.each do |dep|
          next if dep.native?
          next if @merged_gems.include?(dep)
          next if blacklist.include?(dep.name)

          @merges << IronWorkerNG::Mergers::GemMerger.new(dep)
          @merged_gems << dep
        end

        @merges << IronWorkerNG::Mergers::GemMerger.new(gem)
        @merged_gems << gem
      end
    end
  end
end
