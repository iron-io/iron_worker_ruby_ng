require_relative 'features/java'

module IronWorkerNG
  class JavaPackage < IronWorkerNG::Package
    include IronWorkerNG::Features::Java::InstanceMethods

    def initialize(worker_path = nil, worker_klass = nil)
      merge_worker(worker_path, worker_klass) if (not worker_path.nil?) && (not worker_klass.nil?)
    end

    def runtime
      'java'
    end

    def runner
      worker.klass
    end
  end
end
