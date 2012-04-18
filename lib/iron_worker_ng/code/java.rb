require_relative '../feature/java/merge_jar'
require_relative '../feature/java/merge_worker'

module IronWorkerNG
  module Code
    class Java < IronWorkerNG::Code::Base
      include IronWorkerNG::Feature::Java::MergeJar::InstanceMethods
      include IronWorkerNG::Feature::Java::MergeWorker::InstanceMethods

      def create_runner(zip)
        classpath_array = []
      
        @features.each do |f|
          if f.respond_to?(:code_for_classpath)
            classpath_array << f.send(:code_for_classpath)
          end
        end

        classpath = classpath_array.join(':')

        IronWorkerNG::Logger.info "Collected '#{classpath}' classpath"
      
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

java -cp #{classpath} #{worker.klass.nil? ? "-jar #{File.basename(worker.path)}" : worker.klass} "$@"
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

IronWorkerNG::Code::Base.register_type(:name => 'java', :klass => IronWorkerNG::Code::Java)
