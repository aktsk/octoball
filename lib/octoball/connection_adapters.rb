# frozen_string_literal: true

class Octoball
  module ConnectionHandlerSetCurrentShard
    def retrieve_connection(spec_name, shard: ActiveRecord::Base.default_shard)
      conn = super
      conn.current_shard = shard
      conn
    end
  end

  module ConnectionHasCurrentShard
    attr_accessor :current_shard
  end

  ::ActiveRecord::ConnectionAdapters::ConnectionHandler.prepend(ConnectionHandlerSetCurrentShard)
  ::ActiveRecord::ConnectionAdapters::AbstractAdapter.prepend(ConnectionHasCurrentShard)
end
