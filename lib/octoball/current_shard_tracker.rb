# frozen_string_literal: true

class Octoball
  module CurrentShardTracker
    attr_reader :current_shard

    def becomes(klass)
      became = super
      became.instance_variable_set(:@current_shard, current_shard)
      became
    end

    def ==(other)
      super && current_shard == other.current_shard
    end

    module ClassMethods
      private

      def instantiate_instance_of(klass, attributes, column_types = {}, &block)
        result = super
        result.instance_variable_set(:@current_shard, current_shard)
        result
      end
    end
  end

  ::ActiveRecord::Base.prepend(CurrentShardTracker)
  ::ActiveRecord::Base.singleton_class.prepend(CurrentShardTracker::ClassMethods)
end
