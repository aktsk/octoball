require 'spec_helper'

describe Octoball::ConnectionPoolSetCurrentShard, :shards => [] do
  let(:pool) do
    ActiveRecord::ConnectionAdapters::ConnectionPool.new(
      ActiveRecord::Base.connection_pool.pool_config)
  end
  let(:connection) do
    instance_double(ActiveRecord::ConnectionAdapters::AbstractAdapter, :shard => :canada)
  end
  let(:lease) { pool.send(:connection_lease) }

  after do
    lease.release
  end

  describe '#lease_connection' do
    it 'sets the current shard and keeps a successfully checked out connection leased' do
      expect(pool).to receive(:checkout).once.and_return(connection)
      expect(connection).to receive(:current_shard=).with(:canada)

      expect(pool.lease_connection).to equal(connection)
      expect(lease.connection).to equal(connection)
      expect(lease.sticky).to be(true)
    end

    it 'restores the current shard when reusing an existing lease' do
      lease.connection = connection
      expect(pool).not_to receive(:checkout)
      expect(connection).to receive(:current_shard=).with(:canada)

      expect(pool.lease_connection).to equal(connection)
      expect(lease.sticky).to be(true)
    end

    context 'after checkout fails' do
      let(:native_pool) do
        ActiveRecord::ConnectionAdapters::ConnectionPool.new(
          ActiveRecord::Base.connection_pool.pool_config)
      end
      let(:native_lease) { native_pool.send(:connection_lease) }

      before do
        [pool, native_pool].each do |connection_pool|
          allow(connection_pool).to receive(:checkout).and_raise(ActiveRecord::ConnectionTimeoutError)
        end

        # Rails 8.0.0/8.0.1 mark the lease sticky before checkout; patched
        # versions do so afterwards. Octoball must preserve the installed Rails behavior.
        rails_lease_connection = native_pool.method(:lease_connection).super_method
        expect(rails_lease_connection.owner).not_to eq(Octoball::ConnectionPoolSetCurrentShard)
        expect { rails_lease_connection.call }.to raise_error(ActiveRecord::ConnectionTimeoutError)
        expect { pool.lease_connection }.to raise_error(ActiveRecord::ConnectionTimeoutError)
      end

      after { native_lease.release }

      it 'preserves the Rails lease state' do
        expect(lease.connection).to be_nil
        expect(lease.sticky).to eq(native_lease.sticky)
      end

      it 'preserves Rails connection release behavior on subsequent use' do
        allow(connection).to receive(:current_shard=).with(:canada)

        returned_connections = [native_pool, pool].map do |connection_pool|
          returned = []
          allow(connection_pool).to receive(:checkin) { |conn| returned << conn }
          allow(connection_pool).to receive(:checkout).and_return(connection)

          connection_pool.with_connection do |conn|
            expect(conn).to equal(connection)
          end
          returned
        end

        expect(returned_connections.last).to eq(returned_connections.first)
        expect(lease.connection).to equal(native_lease.connection)
        expect(lease.sticky).to eq(native_lease.sticky)
      end
    end
  end
end
