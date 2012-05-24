module IronWorkerNG
  module Code
    module Initializer
      module InstanceMethods
        def initialize_code(*args, &block)
          @name = nil
          @exec = nil

          if args.length == 1 && args[0].class == String
            merge_exec(args[0])
          elsif args.length == 1 && args[0].class == Hash
            @name = args[0][:name] || args[0]['name']

            exec = args[0][:exec] || args[0]['exec'] || args[0][:worker] || args[0]['worker']
            merge_exec(exec) unless exec.nil?
          end

          if args.length == 1 and (opts = args[0]).is_a? Hash and wfile = opts[:workerfile] || opts['workerfile']
            IronCore::Logger.info 'IronWorkerNG', "Processing workerfile #{wfile}"
            eval(File.read(File.expand_path wfile))
          end

          wfiles = ['Workerfile']

          unless name.nil?
            wfiles << name + '.worker'
            wfiles << name + '.workerfile'
          end

          wfiles.each do |wfile|
            if File.exists?(wfile)
              IronCore::Logger.info 'IronWorkerNG', "Processing workerfile #{wfile}"
              eval(File.read(wfile))
            end
          end

          unless block.nil?
            instance_eval(&block)
          end
        end
      end
    end
  end
end
