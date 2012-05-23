require_relative '../feature/java/merge_jar'
require_relative '../feature/java/merge_exec'

module IronWorkerNG
  module Code
    class Java < IronWorkerNG::Code::Base
      include IronWorkerNG::Feature::Java::MergeJar::InstanceMethods
      include IronWorkerNG::Feature::Java::MergeExec::InstanceMethods

      def run_code
        classpath_array = []
      
        @features.each do |f|
          if f.respond_to?(:code_for_classpath)
            classpath_array << f.send(:code_for_classpath)
          end
        end

        classpath = classpath_array.join(':')

        IronCore::Logger.info 'IronWorkerNG', "Collected '#{classpath}' classpath"
        
        <<RUN_CODE
java -cp #{classpath} #{@exec.klass.nil? ? "-jar #{File.basename(@exec.path)}" : @exec.klass} "$@"
RUN_CODE
      end
    end
  end
end

IronWorkerNG::Code::Base.register_type(:name => 'java', :klass => IronWorkerNG::Code::Java)
