require_relative '../simple_gem'

module IronWorkerNG
  module Mergers
    class GemMerger < IronWorkerNG::Mergers::BaseMerger
      attr_reader :gem

      def initialize(gem)
        @gem = gem
      end

      def merge(zip)
        zip.add('./gems/' + @gem.to_s, @gem.path)
        Dir.glob(@gem.path + '/**/**') do |path|
          zip.add('./gems/' + @gem.to_s + path[@gem.path.length .. -1], path)
        end
      end

      def hash_string
        Digest::MD5.hexdigest(@gem.to_s)
      end

      def init_code
        '$:.unshift("#{root}/gems/' + @gem.to_s + '/lib")'
      end
    end

    module InstanceMethods
      attr_reader :merged_gems

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
