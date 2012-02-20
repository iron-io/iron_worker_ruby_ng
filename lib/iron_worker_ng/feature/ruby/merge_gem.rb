require_relative '../../util/simple_gem'

module IronWorkerNG
  module Feature
    module Ruby
      module MergeGem
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :gem

          def initialize(gem)
            @gem = gem
          end

          def hash_string
            Digest::MD5.hexdigest(@gem.to_s)
          end

          def bundle(zip)
            zip.add('./gems/' + @gem.to_s, @gem.path)
            Dir.glob(@gem.path + '/**/**') do |path|
              zip.add('./gems/' + @gem.to_s + path[@gem.path.length .. -1], path)
            end
          end

          def code_for_init
            '$:.unshift("#{root}/gems/' + @gem.to_s + '/lib")'
          end
        end

        module InstanceMethods
          attr_reader :merged_gems

          def merge_gem(name, version = nil)
            @merged_gems ||= []

            blacklist = ['tzinfo']

            gem = IronWorkerNG::Util::SimpleGem.find(name, version)[-1]

            return if gem.nil?
            return if gem.native?
            return if @merged_gems.include?(gem)
            return if blacklist.include?(gem.name)

            deps = gem.deps(true)

            deps.each do |dep|
              next if dep.native?
              next if @merged_gems.include?(dep)
              next if blacklist.include?(dep.name)

              @features << IronWorkerNG::Feature::Ruby::MergeGem::Feature.new(dep)
              @merged_gems << dep
            end

            @features << IronWorkerNG::Feature::Ruby::MergeGem::Feature.new(gem)
            @merged_gems << gem
          end

          def self.included(base)
            IronWorkerNG::Package::Base.register_feature(:name => 'merge_gem', :for_klass => base, :args => 'NAME[,VERSION]')
          end
        end
      end
    end
  end
end
