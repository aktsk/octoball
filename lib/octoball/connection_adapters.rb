# frozen_string_literal: true

class Octoball
  module ConnectionHandlerSetCurrentShard
    def retrieve_connection(spec_name, role: ActiveRecord::Base.current_role, shard: ActiveRecord::Base.current_shard)
      conn = super
      conn.current_shard = shard
      conn
    end
  end

  module ConnectionHasCurrentShard
    attr_accessor :current_shard
  end

  if ActiveRecord.gem_version >= Gem::Version.new('7.2.0')
    module ConnectionPoolSetCurrentShard
      def with_connection(prevent_permanent_checkout: false)
        lease = connection_lease
        if lease.connection
          lease.connection.current_shard = lease.connection.shard
        end

        super
      end

      def active_connection?
        conn = connection_lease.connection
        conn.current_shard = conn.shard if conn
        conn
      end

      def active_connection
        conn = connection_lease.connection
        conn.current_shard = conn.shard if conn
        conn
      end

      def lease_connection
        lease = connection_lease
        lease.sticky = true
        lease.connection ||= checkout
        lease.connection.current_shard = lease.connection.shard
        lease.connection
      end
    end

    ::ActiveRecord::ConnectionAdapters::ConnectionPool.prepend(ConnectionPoolSetCurrentShard)
  end

  ::ActiveRecord::ConnectionAdapters::ConnectionHandler.prepend(ConnectionHandlerSetCurrentShard)
  ::ActiveRecord::ConnectionAdapters::AbstractAdapter.prepend(ConnectionHasCurrentShard)
end
