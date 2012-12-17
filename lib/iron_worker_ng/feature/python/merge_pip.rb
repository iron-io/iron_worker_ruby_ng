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
            install_command = 'pip install --upgrade --install-option="--prefix=' + tmp_dir_name + '" ' + deps_string

            packages_dir = tmp_dir_name + '/lib/python2.7/site-packages'

            ::FileUtils.mkdir_p tmp_dir_name + '/bin'
            ::FileUtils.mkdir_p packages_dir

            system(install_command)

            container_add(container, '__pips__/bin', tmp_dir_name + '/bin', true)
            container_add(container, '__pips__', packages_dir , true)

            FileUtils.rm_rf(tmp_dir_name)
          end
        end
      end
    end
  end
end
