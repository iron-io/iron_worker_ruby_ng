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
            `cd #{pip_dir_name} && curl -O https://pypi.python.org/packages/source/p/pip/#{p}.tar.gz && tar xf #{p}.tar.gz && cd #{p} && python setup.py install --user --root #{pip_dir_name} && cd .. && rm -rf #{p} #{p}.tar.gz`

            pip_packages_dir = ::Dir.glob(pip_dir_name + ENV['HOME'] + '/.local/lib/python*').first
            pip_packages_dir ||= ::Dir.glob(pip_dir_name + ENV['HOME'] + '/Library/Python/*/lib/python*').first

            pip_binary = pip_dir_name + ENV['HOME'] + '/.local/bin/pip'

            unless File.exists?(pip_binary)
              pip_binary = Dir.glob(pip_dir_name + ENV['HOME'] + '/Library/Python/*/bin/pip').first

              if pip_binary.nil?
                IronCore::Logger.error 'IronWorkerNG', 'Unfamiliar Python environment, please switch to full remote build (add \'remote\' to your .worker)', IronCore::Error
              end
            end

            pips_dir_name = ::Dir.tmpdir + '/' + ::Dir::Tmpname.make_tmpname('iron-worker-ng-', 'pips')

            ::Dir.mkdir(pips_dir_name)

            deps_string = @deps.map { |dep| dep.version == '' ? dep.name : dep.name + dep.version }.join(' ')
            install_command = pip_binary + ' install -U -I --user --root ' + pips_dir_name + ' ' + deps_string

            fork do
              ENV['PYTHONPATH'] = pip_packages_dir + '/site-packages:' + pip_packages_dir + '/dist-packages'
              puts `#{install_command}`
            end

            Process.wait

            pips_packages_dir = ::Dir.glob(pips_dir_name + ENV['HOME'] + '/.local/lib/python*').first
            pips_packages_dir ||= ::Dir.glob(pips_dir_name + ENV['HOME'] + '/Library/Python/*/lib/python*').first

            pips_binary_dir = pips_dir_name + ENV['HOME'] + '/.local/bin'

            unless File.exists?(pips_binary_dir)
              pips_binary_dir = ::Dir.glob(pips_dir_name + ENV['HOME'] + '/Library/Python/*/bin').first
            end

            if (not pips_binary_dir.nil?) && File.exists?(pips_binary_dir)
              container_add(container, '__pips__/__bin__', pips_binary_dir, true)
            end

            if File.exists?(pips_packages_dir + '/site-packages')
              container_add(container, '__pips__', pips_packages_dir + '/site-packages' , true)
            end

            if File.exists?(pips_packages_dir + '/dist-packages')
              container_add(container, '__pips__', pips_packages_dir + '/dist-packages' , true)
            end

            FileUtils.rm_rf(pips_dir_name)
            FileUtils.rm_rf(pip_dir_name)
          end
        end
      end
    end
  end
end
