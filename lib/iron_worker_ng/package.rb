require 'tmpdir'
require 'zip/zip'

require_relative 'mergers'

module IronWorkerNG
  class Package
    include IronWorkerNG::Mergers::InstanceMethods

    def initialize(name = nil)
      @name = name
    end

    def name
      return @name unless @name.nil?

      worker = @merges.find { |m| m.class == IronWorkerNG::Mergers::WorkerMerger }
      @name = worker.name
    end

    def create_zip
      zip_name = Dir.tmpdir + '/' + Dir::Tmpname.make_tmpname("iron-worker-ng-", "code.zip")
      
      Zip::ZipFile.open(zip_name, Zip::ZipFile::CREATE) do |zip|
        init_code = execute_merge(zip)

        zip.get_output_stream('runner.rb') do |runner|
          runner.write <<RUNNER
# IronWorker NG #{File.read(File.dirname(__FILE__) + '/../../VERSION').gsub("\n", '')}

root = nil
payload_file = nil

($*.size - 2).downto(0) do |i|
  root = $*[i + 1] if $*[i] == '-d'
  payload_file = $*[i + 1] if $*[i] == '-payload'
end

workers = []

Dir.chdir(root)

#{init_code}
$:.unshift("\#{root}")

require 'json'

payload = JSON.load(File.open(payload_file))

worker = workers.find { |w| w[1] == payload['worker_name'] }
worker = workers[0] if worker.nil?

require worker[0]

worker_class = Kernel.const_get(worker[1])
worker_inst = worker_class.new
worker_inst.run
RUNNER
        end
      end

      zip_name
    end
  end
end
