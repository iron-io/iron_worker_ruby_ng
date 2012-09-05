module IronWorkerNG
  module Feature
    module Common
      module MergeFile
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path
          attr_reader :dest

          def initialize(code, path, dest)
            super(code)

            @path = path
            @dest = dest + (dest.empty? || dest.end_with?('/') ? '' : '/')
          end

          def hash_string
            Digest::MD5.hexdigest(@path + @dest + File.mtime(rebase(@path)).to_i.to_s)
          end

          def bundle(container)
            IronCore::Logger.debug 'IronWorkerNG', "Bundling file with path='#{@path}' and dest='#{@dest}'"

            container_add(container, @dest + File.basename(@path), rebase(@path))
          end

          def command(remote = false)
            if remote
              if IronWorkerNG::Fetcher.remote?(rebase(@path))
                "file '#{rebase(@path)}', '#{@dest}'"
              else
                "file '#{@dest}#{File.basename(@path)}', '#{@dest}'"
              end
            else
              "file '#{@path}', '#{@dest}'"
            end
          end
        end

        module InstanceMethods
          def merge_file(path, dest = '')
            IronCore::Logger.info 'IronWorkerNG', "Merging file with path='#{path}' and dest='#{dest}'"

            @features << IronWorkerNG::Feature::Common::MergeFile::Feature.new(self, path, dest)
          end

          alias :file :merge_file
        end
      end
    end
  end
end
