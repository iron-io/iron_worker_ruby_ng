require 'pathname'

module IronWorkerNG
  module Feature
    module Ruby
      module IronIOConfig
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path
          attr_reader :dest

          def initialize(api, dest)
            @path = File.open(Dir.mktmpdir + '/iron.json', 'w') do |f|
              f << {
                token: api.token,
                project_id: api.project_id
              }.to_json
            end.path
            @dest = dest
            @dest = Pathname.new(dest).cleanpath.to_s + '/' unless @dest.empty?
          end

          def hash_string
            Digest::MD5.hexdigest(@path + @dest + File.mtime(@path).to_i.to_s)
          end

          def bundle(zip)
            IronCore::Logger.debug 'IronWorkerNG', 'Bundling iron.io config'
            zip.add(@dest + File.basename(@path), @path)
          end
        end

        module InstanceMethods
          def iron_io_config(*args)
            dest = ''
            api = IronWorkerNG::Client.new.api
            args.each do |arg|
              dest = arg if arg.is_a? String
              api = arg.api if arg.is_a? IronWorkerNG::Client
            end
            IronCore::Logger.info 'IronWorkerNG',
                                  "Merging iron.io config (dest=#{dest})"
            @features << Feature.new(api, dest)
          end

          def self.included(base)
            IronWorkerNG::Code::Base.register_feature(:name => 'iron_io_config', :for_klass => base, :args => '[DEST]')
          end
        end
      end
    end
  end
end
