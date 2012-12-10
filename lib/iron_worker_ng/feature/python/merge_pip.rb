require 'tmpdir'
require 'fileutils'

module IronWorkerNG
  module Feature
    module Python
      module MergePip
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :deps

          def initialize(code, deps)
            super(code)

            @deps = deps
          end

          def bundle(container)
            IronCore::Logger.debug 'IronWorkerNG', "Bundling pip dependencies"

            tmp_dir_name = ::Dir.tmpdir + '/' + ::Dir::Tmpname.make_tmpname('iron-worker-ng-', 'pips')

            ::Dir.mkdir(tmp_dir_name)

            deps_string = @deps.map { |dep| dep.version == '' ? dep.name : dep.name + '==' + dep.version }.join(' ')
            install_command = 'pip install --upgrade --install-option="--install-purelib=' + tmp_dir_name + '" ' + deps_string

            system(install_command)

            container_add(container, '__pips__', tmp_dir_name, true)

            FileUtils.rm_rf(tmp_dir_name)
          end
        end
      end
    end
  end
end
