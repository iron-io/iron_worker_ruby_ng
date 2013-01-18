require 'iron_worker_ng/feature/java/merge_jar'

module IronWorkerNG
  module Code
    module Runtime
      module Java
        include IronWorkerNG::Feature::Common::MergeExec::InstanceMethods
        include IronWorkerNG::Feature::Java::MergeJar::InstanceMethods

        def runtime_run_code(local = false)
          classpath_array = []

          classpath_array << @exec.path

          @features.each do |f|
            if f.respond_to?(:code_for_classpath)
              classpath_array << f.send(:code_for_classpath)
            end
          end

          classpath = classpath_array.join(':')

          IronCore::Logger.info 'IronWorkerNG', "Collected '#{classpath}' classpath"

          <<RUN_CODE
java -cp #{classpath} #{@exec.arg(:class, 0).nil? ? "-jar #{File.basename(@exec.path)}" : @exec.arg(:class, 0)} "$@"
RUN_CODE
        end
      end
    end
  end
end
