module IronWorkerNG
  module Code
    class Sh < IronWorkerNG::Code::Base

      attr_accessor :file_name

      def runtime
        'sh'
      end

      def runner
        file_name
      end
    end
  end
end

IronWorkerNG::Code::Base.register_type(:name => 'sh', :klass => IronWorkerNG::Code::Sh)
