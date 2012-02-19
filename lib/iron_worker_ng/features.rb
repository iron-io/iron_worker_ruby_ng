require 'digest/md5'

require_relative 'feature'

module IronWorkerNG
  module Features
    @registered_features_methods = []

    def self.registered_features_methods
      @registered_features_methods
    end
    
    def self.register_feature_method(name)
      @registered_features_methods << name
    end

    module Common
      module InstanceMethods
        attr_reader :features

        def hash_string
          Digest::MD5.hexdigest(@feaures.map { |f| f.hash_string }.join)
        end

        def bundle(zip)
          @features.each do |feature|
            feature.bundle(zip)
          end
        end
      end
    end
  end
end
