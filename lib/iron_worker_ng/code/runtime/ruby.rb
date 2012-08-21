require 'tmpdir'
require 'fileutils'

require_relative '../../feature/ruby/merge_gem'
require_relative '../../feature/ruby/merge_gemfile'
require_relative '../../feature/ruby/merge_exec'

module IronWorkerNG
  module Code
    module Runtime
      module Ruby
        include IronWorkerNG::Feature::Ruby::MergeGem::InstanceMethods
        include IronWorkerNG::Feature::Ruby::MergeGemfile::InstanceMethods
        include IronWorkerNG::Feature::Ruby::MergeExec::InstanceMethods

        def runtime_bundle(container)
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
task_id = nil

0.upto($*.length - 2) do |i|
  root = $*[i + 1] if $*[i] == '-d'
  payload_file = $*[i + 1] if $*[i] == '-payload'
  task_id = $*[i + 1] if $*[i] == '-id'
end

ENV['GEM_PATH'] = ([root + '__gems__'] + (ENV['GEM_PATH'] || '').split(':')).join(':')

$:.unshift("\#{root}")

require 'json'

@iron_task_id = task_id

@payload = File.read(payload_file)

params = {}
begin
  params = JSON.parse(@payload)
rescue
end

@params = IronWorkerNGHash.new(params)

def payload
  @payload
end

def params
  @params
end

def iron_task_id
  @iron_task_id
end

require '#{File.basename(@exec.path)}'

unless #{@exec.klass == nil}
  exec_class = Kernel.const_get('#{@exec.klass}')
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
#{local ? 'GEM_PATH="" ' : ''}ruby __runner__.rb "$@"
RUN_CODE
        end

        def install
          gemfile_dir = Dir.tmpdir + '/' + Dir::Tmpname.make_tmpname('iron-worker-ng-', 'gemfile')

          FileUtils.mkdir(gemfile_dir)

          gemfile = File.open(gemfile_dir + '/Gemfile', 'w')

          gemfile.puts('source :rubygems')

          @merge_gem_reqs.each do |req|
            gemfile.puts("gem '#{req.name}', '#{req.requirement.to_s}'")
          end

          gemfile.close

          puts `cd #{gemfile_dir} && bundle install`

          FileUtils.rm_r(gemfile_dir)
        end
      end
    end
  end
end
