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

parsed_payload = {}
begin
  parsed_payload = JSON.parse(@payload)
rescue
end

@iron_token = parsed_payload['token'] || nil
@iron_project_id = parsed_payload['project_id'] || nil
@params = parsed_payload['params'] || {}

keys = @params.keys
keys.each do |key|
  @params[key.to_sym] = @params[key]
end

def payload
  @payload
end

def iron_task_id
  @iron_task_id
end

def iron_token
  @iron_token
end

def iron_project_id
  @iron_project_id
end

def params
  @params
end

require '#{File.basename(@exec.path)}'

exec_class = nil

begin
  exec_class = Kernel.const_get('#{@exec.klass}')
rescue
end

unless exec_class.nil?
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

      def runtime
        'ruby'
      end

      def runner
        '__runner__.rb'
      end
    end
  end
end

IronWorkerNG::Code::Base.register_type(:name => 'ruby', :klass => IronWorkerNG::Code::Ruby)
