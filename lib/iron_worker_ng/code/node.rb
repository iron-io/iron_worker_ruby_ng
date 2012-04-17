require_relative '../feature/node/merge_worker'

module IronWorkerNG
  module Code
    class Node < IronWorkerNG::Code::Base
      include IronWorkerNG::Feature::Node::MergeWorker::InstanceMethods

      def create_runner(zip)
        zip.get_output_stream(runner) do |runner|
          runner.write <<RUNNER
#!/bin/sh
# iron_worker_ng-#{IronWorkerNG.version}

root() {
  while [ $# -gt 0 ]; do
    if [ "$1" = "-d" ]; then
      printf "%s\n" "$2"
      break
    fi
  done
}

cd "$(root "$@")"

node #{File.basename(worker.path)} "$@"
RUNNER
        end
      end

      def runtime
        'sh'
      end

      def runner
        '__runner__.sh'
      end
    end
  end
end

IronWorkerNG::Code::Base.register_type(:name => 'node', :klass => IronWorkerNG::Code::Node)
