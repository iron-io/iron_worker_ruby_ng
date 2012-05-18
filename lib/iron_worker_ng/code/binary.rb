require_relative '../feature/binary/merge_exec'

module IronWorkerNG
  module Code
    class Binary < IronWorkerNG::Code::Base
      include IronWorkerNG::Feature::Binary::MergeExec::InstanceMethods

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

chmod +x #{File.basename(@exec.path)}

LD_LIBRARY_PATH=. ./#{File.basename(@exec.path)} "$@"
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

IronWorkerNG::Code::Base.register_type(:name => 'binary', :klass => IronWorkerNG::Code::Binary)
