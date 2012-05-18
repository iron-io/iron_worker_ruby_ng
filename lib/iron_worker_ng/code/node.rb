require_relative '../feature/node/merge_exec'

module IronWorkerNG
  module Code
    class Node < IronWorkerNG::Code::Base
      include IronWorkerNG::Feature::Node::MergeExec::InstanceMethods

      def create_runner(zip)
        zip.get_output_stream(runner) do |runner|
          runner.write <<RUNNER
#!/bin/sh
# iron_worker_ng-#{IronWorkerNG.full_version}

root() {
  while [ $# -gt 0 ]; do
    if [ "$1" = "-d" ]; then
      printf "%s\n" "$2"
      break
    fi
  done
}

cd "$(root "$@")"

node #{File.basename(@exec.path)} "$@"
RUNNER
        end
      end

      def runtime(runtime = nil)
        'sh'
      end

      def runner
        '__runner__.sh'
      end
    end
  end
end

IronWorkerNG::Code::Base.register_type(:name => 'node', :klass => IronWorkerNG::Code::Node)
