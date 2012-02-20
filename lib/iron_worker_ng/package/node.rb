require_relative '../feature/node/merge_worker'

module IronWorkerNG
  module Package
    class Node < IronWorkerNG::Package::Base
      include IronWorkerNG::Feature::Node::MergeWorker::InstanceMethods

      def create_runner(zip, init_code)
        zip.get_output_stream('runner.rb') do |runner|
          runner.write <<RUNNER
# IronWorker NG #{File.read(File.dirname(__FILE__) + '/../../../VERSION').gsub("\n", '')}

root = nil

($*.size - 2).downto(0) do |i|
  root = $*[i + 1] if $*[i] == '-d'
end

Dir.chdir(root)

#{init_code}

puts `node \#{worker_file_name} \#{$*.join(' ')}`
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
end

IronWorkerNG::Package::Base.register_type(:name => 'node', :klass => IronWorkerNG::Package::Node)
