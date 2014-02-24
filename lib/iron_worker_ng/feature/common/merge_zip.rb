module IronWorkerNG
  module Feature
    module Common
      module MergeZip
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path
          attr_reader :dest

          def initialize(code, path, dest)
            super(code)

            @path = path
            @dest = dest + (dest.empty? || dest.end_with?('/') ? '' : '/')
          end

          def bundle(container)
            IronCore::Logger.debug 'IronWorkerNG', "Bundling zip with path='#{@path}' and dest='#{@dest}'"

            if (not @code.full_remote_build) || (not IronWorkerNG::Fetcher.remote?(rebase(@path)))
              tmp_dir_name = ::Dir.tmpdir + '/' + ::Dir::Tmpname.make_tmpname('iron-worker-ng-', 'zip')

              ::Dir.mkdir(tmp_dir_name)

              IronWorkerNG::Fetcher.fetch_to_file(rebase(@path)) do |zip|
                zipf = ::Zip::ZipFile.open(zip)
                zipf.restore_permissions = true

                zipf.each do |f|
                  next if zipf.get_entry(f).ftype == :directory

                  FileUtils::mkdir_p(tmp_dir_name + '/' + File.dirname(f.name))
                  zipf.get_entry(f).extract(tmp_dir_name + '/' + f.name)
                end

                zipf.each do |f|
                  next if zipf.get_entry(f).ftype == :directory

                  container_add(container, @dest + f.name, tmp_dir_name + '/' + f.name)
                end
              end

              container.commit

              FileUtils.rm_rf(tmp_dir_name)
            end
          end

          def build_command
            if @code.remote_build_command || @code.full_remote_build
              if @code.full_remote_build && IronWorkerNG::Fetcher.remote?(rebase(@path))
                "zip '#{rebase(@path)}', '#{@dest}'"
              else
                "zip '#{@code.dest_dir}#{@dest}#{File.basename(@path)}', '#{@dest}'"
              end
            else
              nil
            end
          end
        end

        module InstanceMethods
          def merge_zip(path, dest = '')
            IronCore::Logger.info 'IronWorkerNG', "Merging zip with path='#{path}' and dest='#{dest}'"

            @features << IronWorkerNG::Feature::Common::MergeZip::Feature.new(self, path, dest)
          end

          alias :zip :merge_zip
        end
      end
    end
  end
end
