require 'digest/md5'

require_relative 'feature'

module IronWorkerNG
  module Features
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
