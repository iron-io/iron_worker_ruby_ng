require 'tmpdir'
require 'fileutils'

require 'iron_worker_ng/feature/ruby/merge_gem_dependency'
require 'iron_worker_ng/feature/ruby/merge_gemfile'
require 'iron_worker_ng/feature/ruby/merge_gem'

module IronWorkerNG
  module Code
    module Runtime
      module Ruby
        include IronWorkerNG::Feature::Common::MergeExec::InstanceMethods
        include IronWorkerNG::Feature::Ruby::MergeGemDependency::InstanceMethods
        include IronWorkerNG::Feature::Ruby::MergeGemfile::InstanceMethods

        def runtime_bundle(container, local = false)
          container.get_output_stream(@dest_dir + '__runner__.rb') do |runner|
            runner.write <<RUBY_RUNNER
# #{IronWorkerNG.full_version}

module IronWorkerNG
#{File.read(File.dirname(__FILE__) + '/../../../3rdparty/hashie/merge_initializer.rb')}
#{File.read(File.dirname(__FILE__) + '/../../../3rdparty/hashie/indifferent_access.rb')}
end

class IronWorkerNGHash < Hash
  include IronWorkerNG::Hashie::Extensions::MergeInitializer
  include IronWorkerNG::Hashie::Extensions::IndifferentAccess
end

root = nil
payload_file = nil
config_file = nil
task_id = nil

0.upto($*.length - 2) do |i|
  root = $*[i + 1] if $*[i] == '-d'
  payload_file = $*[i + 1] if $*[i] == '-payload'
  config_file = $*[i + 1] if $*[i] == '-config'
  task_id = $*[i + 1] if $*[i] == '-id'
end

ENV['GEM_PATH'] = ([root + '__gems__'] + (ENV['GEM_PATH'] || '').split(':')).join(':')
ENV['GEM_HOME'] = root + '__gems__'

$:.unshift("\#{root}")

require 'json'
require 'yaml'

@iron_task_id = task_id

@payload = File.read(payload_file)

params = {}
begin
  params = JSON.parse(@payload)
rescue
end

@config = nil
if config_file
  @config = File.read(config_file)
  begin
    @config = JSON.parse(@config)
    @config = IronWorkerNGHash.new(@config)
  rescue
    # try yaml
    begin
      @config = YAML.load(@config)
      @config = IronWorkerNGHash.new(@config)
    rescue
    end
  end
end

@params = IronWorkerNGHash.new(params)

def payload
  @payload
end

def config
  @config
end

def params
  @params
end

def iron_task_id
  @iron_task_id
end

require '#{File.basename(@exec.path)}'

unless #{@exec.arg(:class, 0) == nil}
  exec_class = Kernel.const_get('#{@exec.arg(:class, 0)}')
  exec_inst = exec_class.new

  params.keys.each do |param|
    if param.class == String
      if exec_inst.respond_to?(param + '=')
        exec_inst.send(param + '=', params[param])
      end
    end
  end

  exec_inst.run
end
RUBY_RUNNER
          end
        end

        def runtime_run_code(local = false)
          <<RUN_CODE
ruby __runner__.rb "$@"
RUN_CODE
        end

        def install(standalone = false)
          gemfile_dir = nil
          gemfile = nil

          if standalone
            gemfile = File.open('Gemfile', 'w')
          else
            gemfile_dir = ::Dir.tmpdir + '/' + ::Dir::Tmpname.make_tmpname('iron-worker-ng-', 'gemfile')

            FileUtils.mkdir(gemfile_dir)

            gemfile = File.open(gemfile_dir + '/Gemfile', 'w')
          end

          gemfile.puts('source \'http://rubygems.org\'')

          deps = @features.reject { |f| f.class != IronWorkerNG::Feature::Ruby::MergeGemDependency::Feature }

          deps.each do |dep|
            gemfile.puts("gem '#{dep.name}', '#{dep.version}'")
          end

          gemfile.close

          if standalone
            puts `bundle install --standalone`
          else
            puts `cd #{gemfile_dir} && bundle install`

            FileUtils.rm_r(gemfile_dir)
          end
        end
      end
    end
  end
end
