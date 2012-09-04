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

          def initialize(code, spec)
            super(code)

            @spec = spec
          end

          def gem_path
            path = @spec.full_gem_path

            # bundler fix

            ['/gems/' + @spec.full_name, '/gems'].each do |bad_part|
              path.gsub!(bad_part + bad_part, bad_part)
            end

            path
          end

          def hash_string
            Digest::MD5.hexdigest(@spec.full_name)
          end

          def bundle(container)
            if @spec.extensions.length == 0 || IronWorkerNG::Feature::Ruby::MergeGem.merge_binary?
              IronCore::Logger.debug 'IronWorkerNG', "Bundling ruby gem with name='#{@spec.name}' and version='#{@spec.version}'"

              container_add(container, '__gems__/gems/' + @spec.full_name, gem_path)
              container_add(container, "__gems__/specifications/#{@spec.full_name}.gemspec", gem_path + '/../../specifications/' + @spec.full_name + '.gemspec')
            else
              IronCore::Logger.warn 'IronWorkerNG', "Skipping ruby gem with name='#{@spec.name}' and version='#{@spec.version}' as it contains native extensions"
            end
          end
        end
      end
    end
  end
end
