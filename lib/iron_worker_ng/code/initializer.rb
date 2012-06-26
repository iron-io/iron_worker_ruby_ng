module IronWorkerNG
  module Code
    module Initializer
      module InstanceMethods
        def initialize_code(*args, &block)
          @name = nil
          @exec = nil

          wfiles = []

          if args.length == 1 && args[0].class == String
            name = args[0]

            if name.end_with?('.worker') || name.end_with?('.workerfile')
              @name = name.gsub(/\.worker$/, '').gsub(/\.workerfile$/, '')
            else
              merge_exec(name)
            end
          elsif args.length == 1 && args[0].class == Hash
            @name = args[0][:name] || args[0]['name']

            unless @name.nil?
              if @name.end_with?('.worker') || @name.end_with?('.workerfile')
                @name = @name.gsub(/\.worker$/, '').gsub(/\.workerfile$/, '')
              end
            end

            exec = args[0][:exec] || args[0]['exec'] || args[0][:worker] || args[0]['worker']
            merge_exec(exec) unless exec.nil?
          end

          if args.length == 1 && args[0].class == Hash && (args[0][:workerfile] || args[0]['workerfile'])
            wfiles << args[0][:workerfile] || args[0]['workerfile']
          end

          if @name.nil? and @exec
            @name = guess_name_for_path(@exec.path)
          end

          unless @name.nil?
            wfiles << @name + '.worker'
            wfiles << @name + '.workerfile'
          end

          wfiles << 'Workerfile'

          wfiles.each do |wfile|
            if File.exists?(wfile)
              eval(File.read(wfile))

              @base_dir = File.dirname(wfile) == '.' ? '' : File.dirname(wfile) + '/'

              break
            end
          end

          unless block.nil?
            instance_eval(&block)
          end

          if @name.nil? and @exec
            @name = guess_name_for_path(@exec.path)
          end

          @name = File.basename(@name) unless @name.nil?
        end

        def guess_name_for_path(path)
          File.basename(path).gsub(/\..*$/, '').capitalize.gsub(/_./) { |x| x[1].upcase }
        end
      end
    end
  end
end
