require_relative '../feature/java/merge_jar'
require_relative '../feature/java/merge_worker'

module IronWorkerNG
  module Code
    class Java < IronWorkerNG::Code::Base
      include IronWorkerNG::Feature::Java::MergeJar::InstanceMethods
      include IronWorkerNG::Feature::Java::MergeWorker::InstanceMethods

      def create_runner(zip, init_code)
        IronWorkerNG::Logger.info 'Creating java runner'

        classpath_array = []
      
        @features.each do |f|
          if f.respond_to?(:code_for_classpath)
            classpath_array << f.send(:code_for_classpath)
          end
        end

        classpath = classpath_array.join(':')

        IronWorkerNG::Logger.info "Collected #{classpath} classpath"
      
        zip.get_output_stream('runner.rb') do |runner|
          runner.write <<RUNNER
# iron_worker_ng-#{IronWorkerNG.version}

root = nil

($*.length - 2).downto(0) do |i|
  root = $*[i + 1] if $*[i] == '-d'
end

Dir.chdir(root)

#{init_code}

puts `java -cp #{classpath} #{worker.klass} \#{$*.join(' ')}`
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

IronWorkerNG::Code::Base.register_type(:name => 'java', :klass => IronWorkerNG::Code::Java)
