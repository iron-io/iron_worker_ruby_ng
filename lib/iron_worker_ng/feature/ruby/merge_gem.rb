require 'bundler'

module IronWorkerNG
  module Feature
    module Ruby
      module MergeGem
        def self.merge_binary?
          @merge_binary ||= false
        end

        def self.merge_binary=(merge_binary)
          @merge_binary = merge_binary
        end

        class Feature < IronWorkerNG::Feature::Base
          attr_reader :spec

          def initialize(spec)
            @spec = spec
          end

          def gem_path
            path = @spec.full_gem_path

            # when running under bundle exec it sometimes duplicates gem path suffix
            
            suffix_index = path.rindex('/gems/')
            suffix = path[suffix_index .. -1]

            if path.end_with?(suffix + suffix)
              path = path[0 .. suffix_index - 1]
            end

            path
          end

          def hash_string
            Digest::MD5.hexdigest(@spec.full_name)
          end

          def bundle(zip)
            if @spec.extensions.length == 0 || IronWorkerNG::Feature::Ruby::MergeGem.merge_binary?
              IronCore::Logger.debug 'IronWorkerNG', "Bundling ruby gem with name='#{@spec.name}' and version='#{@spec.version}'"

              zip.add('__gems__/gems/' + @spec.full_name, gem_path)
              zip.add("__gems__/specifications/#{@spec.full_name}.gemspec",
                      File.expand_path(gem_path + '/../../specifications/' +
                                       @spec.full_name + '.gemspec'))
              Dir.glob(gem_path + '/**/**') do |path|
                zip.add('__gems__/gems/' + @spec.full_name + path[gem_path.length .. -1], path)
              end
            else
              IronCore::Logger.warn 'IronWorkerNG', "Skipping ruby gem with name='#{@spec.name}' and version='#{@spec.version}' as it contains native extensions"
            end
          end

          def code_for_gempath
            if @spec.extensions.length == 0 || IronWorkerNG::Feature::Ruby::MergeGem.merge_binary?
              '$:.unshift("#{root}/__gems__/gems/' + @spec.full_name + '/lib")'
            else
              '# native gem ' + @spec.full_name
            end
          end
        end

        module InstanceMethods
          attr_reader :merge_gem_reqs

          def merge_gem(name, version = '>= 0')
            IronCore::Logger.info 'IronWorkerNG', "Adding ruby gem dependency with name='#{name}' and version='#{version}'"

            @merge_gem_reqs ||= []
            @merge_gem_reqs << Bundler::Dependency.new(name, version.split(', '))
          end

          alias :gem :merge_gem

          def merge_gem_fixate
            IronCore::Logger.info 'IronWorkerNG', 'Fixating gems dependencies'

            @merge_gem_reqs ||= []

            @features.reject! do |f|
              f.class == IronWorkerNG::Feature::Ruby::MergeGem::Feature
            end

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
                spec.__materialize__

                IronCore::Logger.info 'IronWorkerNG', "Merging ruby gem with name='#{spec.name}' and version='#{spec.version}'"

                @features << IronWorkerNG::Feature::Ruby::MergeGem::Feature.new(spec)
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
