# frozen_string_literal: true

class Octoball
  module ConnectionHandlingAvoidAutoLoadProxy
    private

    if ActiveRecord.gem_version < Gem::Version.new('7.1.0')
      def swap_connection_handler(handler, &blk)
        old_handler, ActiveRecord::Base.connection_handler = ActiveRecord::Base.connection_handler, handler
        return_value = yield
        return_value.load if !return_value.respond_to?(:ar_relation) && return_value.is_a?(ActiveRecord::Relation)
        return_value
      ensure
        ActiveRecord::Base.connection_handler = old_handler
      end
    end
  end

  ::ActiveRecord::Base.extend(ConnectionHandlingAvoidAutoLoadProxy)
end
