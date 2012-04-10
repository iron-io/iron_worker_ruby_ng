require_relative '../feature/node/merge_worker'

module IronWorkerNG
  module Code
    class Node < IronWorkerNG::Code::Base
      include IronWorkerNG::Feature::Node::MergeWorker::InstanceMethods

      def create_runner(zip, init_code)
        zip.get_output_stream('runner.rb') do |runner|
          runner.write <<RUNNER
# iron_worker_ng-#{IronWorkerNG.version}

root = nil

($*.length - 2).downto(0) do |i|
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
        '__runner__.rb'
      end
    end
  end
end

IronWorkerNG::Code::Base.register_type(:name => 'node', :klass => IronWorkerNG::Code::Node)
