require_relative '../feature/ruby/merge_gem'
require_relative '../feature/ruby/merge_gemfile'
require_relative '../feature/ruby/merge_exec'

module IronWorkerNG
  module Code
    class Ruby < IronWorkerNG::Code::Base
      include IronWorkerNG::Feature::Ruby::MergeGem::InstanceMethods
      include IronWorkerNG::Feature::Ruby::MergeGemfile::InstanceMethods
      include IronWorkerNG::Feature::Ruby::MergeExec::InstanceMethods

      def create_runner(zip)
        gempath_code_array = []
      
        @features.each do |f|
          if f.respond_to?(:code_for_gempath)
            gempath_code_array << f.send(:code_for_gempath)
          end
        end

        gempath_code = gempath_code_array.join("\n")

        zip.get_output_stream(runner) do |runner|
          runner.write <<RUNNER
# iron_worker_ng-#{IronWorkerNG.version}

module IronWorkerNG
  #{ File.read( File.dirname(__FILE__) + '/../hashie/merge_initializer.rb' ) }
  #{ File.read( File.dirname(__FILE__) + '/../hashie/indifferent_access.rb' ) }
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

Dir.chdir(root)

#{gempath_code}
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
RUNNER
        end
      end

      def runtime(runtime = nil)
        'ruby'
      end

      def runner
        '__runner__.rb'
      end
    end
  end
end

IronWorkerNG::Code::Base.register_type(:name => 'ruby', :klass => IronWorkerNG::Code::Ruby)
