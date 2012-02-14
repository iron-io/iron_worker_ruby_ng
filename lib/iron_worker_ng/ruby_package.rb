require 'tmpdir'
require 'zip/zip'

require_relative 'features/ruby'

module IronWorkerNG
  class RubyPackage < IronWorkerNG::Package
    include IronWorkerNG::Features::Ruby::InstanceMethods

    def initialize(worker_path = nil)
      merge_worker(worker_path) unless worker_path.nil?
    end

    def create_runner(zip)
      init_code = ''

      @features.each do |f|
        if f.respond_to?(:code_for_init)
          init_code += f.send(:code_for_init) + "\n"
        end
      end

      zip.get_output_stream('runner.rb') do |runner|
        runner.write <<RUNNER
# IronWorker NG #{File.read(File.dirname(__FILE__) + '/../../VERSION').gsub("\n", '')}

root = nil
payload_file = nil
task_id = nil

($*.size - 2).downto(0) do |i|
  root = $*[i + 1] if $*[i] == '-d'
  payload_file = $*[i + 1] if $*[i] == '-payload'
  task_id = $*[i + 1] if $*[i] == '-id'
end

Dir.chdir(root)

#{init_code}
$:.unshift("\#{root}")

require 'json'

payload = JSON.load(File.open(payload_file))

require worker_file_name

worker_class = Kernel.const_get(worker_class_name)
worker_inst = worker_class.new

class << worker_inst
  attr_accessor :iron_io_project_id
  attr_accessor :iron_io_token
  attr_accessor :iron_worker_task_id
  attr_accessor :params
end

worker_inst.iron_io_project_id = payload['project_id']
worker_inst.iron_io_token = payload['token']
worker_inst.iron_worker_task_id = task_id
worker_inst.params = payload['params']

worker_inst.run
RUNNER
      end
    end

    def runtime
      'ruby'
    end

    def runner
      'runner.rb'
    end
  end
end
