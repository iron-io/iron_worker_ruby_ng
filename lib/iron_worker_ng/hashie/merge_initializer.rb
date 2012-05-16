# source: https://github.com/intridea/hashie/blob/6d21c6868512603e77a340827ec91ecd3bcef078/lib/hashie/extensions/merge_initializer.rb
module Hashie
  module Extensions
    # The MergeInitializer is a super-simple mixin that allows
    # you to initialize a subclass of Hash with another Hash
    # to give you faster startup time for Hash subclasses. Note
    # that you can still provide a default value as a second
    # argument to the initializer.
    #
    # @example
    #   class MyHash < Hash
    #     include Hashie::Extensions::MergeInitializer
    #   end
    #
    #   h = MyHash.new(:abc => 'def')
    #   h[:abc] # => 'def'
    #
    module MergeInitializer
      def initialize(hash = {}, default = nil, &block)
        default ? super(default) : super(&block)
        update(hash)
      end
    end
  end
end
