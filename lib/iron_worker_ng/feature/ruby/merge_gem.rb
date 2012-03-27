require 'bundler'

module IronWorkerNG
  module Feature
    module Ruby
      module MergeGem
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :spec

          def initialize(spec)
            @spec = spec
          end

          def hash_string
            Digest::MD5.hexdigest(@spec.full_name)
          end

          def bundle(zip)
            if @spec.extensions.length == 0
              zip.add('gems/' + @spec.full_name, @spec.full_gem_path)
              Dir.glob(@spec.full_gem_path + '/**/**') do |path|
                zip.add('gems/' + @spec.full_name + path[@spec.full_gem_path.length .. -1], path)
              end
            end
          end

          def code_for_init
            if @spec.extensions.length == 0
              '$:.unshift("#{root}/gems/' + @spec.full_name + '/lib")'
            else
              '# native gem ' + @spec.full_name
            end
          end
        end

        module InstanceMethods
          attr_reader :merge_gem_reqs

          def merge_gem(name, version = '>= 0')
            @merge_gem_reqs ||= []

            @merge_gem_reqs << Bundler::Dependency.new(name, version.split(', '))
          end

          def merge_gem_fixate
            @merge_gem_reqs ||= []

            @features.reject! { |f| f.class == IronWorkerNG::Feature::Ruby::MergeGem::Feature }

            if @merge_gem_reqs.length > 0
              reqs = @merge_gem_reqs.map { |req| Bundler::DepProxy.new(req, Gem::Platform::RUBY) }

              source = nil
              begin
                source = Bundler::Source::Rubygems.new
              rescue Bundler::GemfileNotFound
                ENV['BUNDLE_GEMFILE'] = 'Gemfile'
                source = Bundler::Source::Rubygems.new
              end

              index = Bundler::Index.build { |index| index.use source.specs }

              spec_set = Bundler::Resolver.resolve(reqs, index)

              spec_set.to_a.each do |spec|
                @features << IronWorkerNG::Feature::Ruby::MergeGem::Feature.new(spec.__materialize__)
              end
            end
          end

          def self.included(base)
            IronWorkerNG::Code::Base.register_feature(:name => 'merge_gem', :for_klass => base, :args => 'NAME[,VERSION]')
          end
        end
      end
    end
  end
end
