require 'bundler'

module IronWorkerNG
  module Feature
    module Ruby
      module MergeGemDependency
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :name
          attr_reader :version

          def initialize(code, name, version)
            super(code)

            @name = name
            @version = version
          end

          def build_command
            if @code.full_remote_build
              "gem '#{@name}', '#{@version}'"
            elsif @code.remote_build_command
              "dir '__build__/__gems__'"
            else
              nil
            end
          end
        end

        module InstanceMethods
          def merge_gem(name, version = '>= 0')
            IronCore::Logger.info 'IronWorkerNG', "Adding ruby gem dependency with name='#{name}' and version='#{version}'"

            @features << IronWorkerNG::Feature::Ruby::MergeGemDependency::Feature.new(self, name, version)

            unless @fixators.include?(:merge_gem_dependency_fixate)
              @fixators << :merge_gem_dependency_fixate
            end
          end

          alias :gem :merge_gem

          def merge_gem_dependency_fixate
            if not full_remote_build
              IronCore::Logger.info 'IronWorkerNG', 'Fixating gems dependencies'

              @features.reject! { |f| f.class == IronWorkerNG::Feature::Ruby::MergeGem::Feature }

              deps = @features.reject { |f| f.class != IronWorkerNG::Feature::Ruby::MergeGemDependency::Feature }

              if deps.length > 0
                deps = deps.map { |dep| Bundler::DepProxy.new(Bundler::Dependency.new(dep.name, dep.version.split(', ')), Gem::Platform::RUBY) }

                source = nil

                begin
                  source = Bundler::Source::Rubygems.new
                rescue Bundler::GemfileNotFound
                  ENV['BUNDLE_GEMFILE'] = 'Gemfile'
                  source = Bundler::Source::Rubygems.new
                end

                index = Bundler::Index.build { |index| index.use source.specs }

                spec_set = Bundler::Resolver.resolve(deps, index)

                spec_set.to_a.each do |spec|
                  spec.__materialize__

                  IronCore::Logger.info 'IronWorkerNG', "Merging ruby gem with name='#{spec.name}' and version='#{spec.version}'"

                  @features << IronWorkerNG::Feature::Ruby::MergeGem::Feature.new(self, spec)
                end
              end
            end
          end
        end
      end
    end
  end
end
