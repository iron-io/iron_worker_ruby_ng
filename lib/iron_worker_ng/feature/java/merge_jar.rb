module IronWorkerNG
  module Feature
    module Java
      module MergeJar
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path

          def initialize(code, path)
            super(code)

            @path = path
          end

          def hash_string
            Digest::MD5.hexdigest(@path + File.mtime(rebase(@path)).to_i.to_s)
          end

          def bundle(zip)
            IronCore::Logger.debug 'IronWorkerNG', "Bundling java jar with path='#{@path}'"

            zip_add(zip, File.basename(@path), rebase(@path))
          end

          def code_for_classpath
            File.basename(@path)
          end
        end

        module InstanceMethods
          def merge_jar(path)
            IronCore::Logger.info 'IronWorkerNG', "Merging java jar with path='#{path}'"

            @features << IronWorkerNG::Feature::Java::MergeJar::Feature.new(self, path)
          end

          alias :jar :merge_jar

          def self.included(base)
            IronWorkerNG::Code.register_feature(:name => 'merge_jar', :for_klass => base, :args => 'PATH')
          end
        end
      end
    end
  end
end
