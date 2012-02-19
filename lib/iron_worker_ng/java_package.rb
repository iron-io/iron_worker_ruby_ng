require_relative 'features/java'

module IronWorkerNG
  class JavaPackage < IronWorkerNG::Package
    include IronWorkerNG::Features::Java::InstanceMethods

    def initialize(worker_path = nil, worker_klass = nil)
      merge_worker(worker_path, worker_klass) if (not worker_path.nil?) && (not worker_klass.nil?)
    end

    def create_runner(zip)
      classpath_array = []
      
      @features.each do |f|
        if f.respond_to?(:code_for_classpath)
          classpath_array << f.send(:code_for_classpath)
        end
      end

      classpath = classpath_array.join(':')
      
      zip.get_output_stream('runner.rb') do |runner|
        runner.write <<RUNNER
# IronWorker NG #{File.read(File.dirname(__FILE__) + '/../../VERSION').gsub("\n", '')}

root = nil

($*.size - 2).downto(0) do |i|
  root = $*[i + 1] if $*[i] == '-d'
end

Dir.chdir(root)

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
