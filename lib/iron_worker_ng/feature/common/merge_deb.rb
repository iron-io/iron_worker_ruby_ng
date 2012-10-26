require 'tmpdir'
require 'fileutils'

module IronWorkerNG
  module Feature
    module Common
      module MergeDeb
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path

          def initialize(code, path)
            super(code)

            @path = path
          end

          def bundle(container)
            IronCore::Logger.debug 'IronWorkerNG', "Bundling deb with path='#{@path}'"

            if (not @code.remote_build_command) && (not @code.full_remote_build)
              IronWorkerNG::Fetcher.fetch_to_file(rebase(@path)) do |deb|
                if deb.nil? || (not File.exists?(deb))
                  IronCore::Logger.error 'IronWorkerNG', "Can't find deb with path='#{@path}'"
                end

                tmp_dir_name = ::Dir.tmpdir + '/' + ::Dir::Tmpname.make_tmpname('iron-worker-ng-', 'deb')

                ::Dir.mkdir(tmp_dir_name)

                `dpkg -x #{deb} #{tmp_dir_name}`

                container_add(container, '__debs__', tmp_dir_name, true)

                FileUtils.rm_rf(tmp_dir_name)
              end
            else
              if (not @code.full_remote_build) || (not IronWorkerNG::Fetcher.remote?(rebase(@path)))
                container_add(container, File.basename(@path), rebase(@path))
              end
            end
          end

          def build_command
            if @code.remote_build_command || @code.full_remote_build
              if @code.full_remote_build && IronWorkerNG::Fetcher.remote?(rebase(@path))
                "deb '#{rebase(@path)}'"
              else
                "deb '#{@code.dest_dir}#{File.basename(@path)}'"
              end
            else
              nil
            end
          end
        end

        module InstanceMethods
          def merge_deb(path)
            IronCore::Logger.info 'IronWorkerNG', "Merging deb with path='#{path}'"

            @features << IronWorkerNG::Feature::Common::MergeDeb::Feature.new(self, path)
          end

          alias :deb :merge_deb
        end
      end
    end
  end
end
