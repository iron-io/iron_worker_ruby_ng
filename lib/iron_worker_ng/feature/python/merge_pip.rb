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

            pip_dir_name = ::Dir.tmpdir + '/' + ::Dir::Tmpname.make_tmpname('iron-worker-ng-', 'pip')

            ::Dir.mkdir(pip_dir_name)

            p = 'pip-1.3.1'
            `cd #{pip_dir_name} && curl -O https://pypi.python.org/packages/source/p/pip/#{p}.tar.gz && tar xf #{p}.tar.gz && cd #{p} && python setup.py install --root #{pip_dir_name} && rm -rf #{p} #{p}.tar.gz`

            local = File.exists?(pip_dir_name + '/usr/local/lib') ? 'local' : ''

            pip_packages_dir = Dir.glob(pip_dir_name + '/usr/' + local + '/lib/*python*').first

            deps_string = @deps.map { |dep| dep.version == '' ? dep.name : dep.name + dep.version }.join(' ')
            install_command = pip_dir_name + '/usr/' + local + '/bin/pip install --user -U -I ' + deps_string

            fork do
              ENV['PYTHONPATH'] = pip_packages_dir + '/site_packages:' + pip_packages_dir + '/dist-packages'
              puts `#{install_command}`
            end

            Process.wait

            pips_packages_dir = Dir.glob(ENV['HOME'] + '/.local/lib/*python*').first

            if File.exists?(ENV['HOME'] + '/.local/bin')
              container_add(container, '__pips__/__bin__', ENV['HOME'] + '/.local/bin', true)
            end

            if File.exists?(pips_packages_dir + '/site-packages')
              container_add(container, '__pips__', pips_packages_dir + '/site-packages' , true)
            end

            if File.exists?(pips_packages_dir + '/dist-packages')
              container_add(container, '__pips__', pips_packages_dir + '/dist-packages' , true)
            end

            FileUtils.rm_rf(pip_dir_name)
          end
        end
      end
    end
  end
end
