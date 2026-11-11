require 'spec_helper'

describe Octoball::LogSubscriber, :shards => [:canada] do
  before :each do
    @out = StringIO.new
    @log = Logger.new(@out)
    ActiveRecord::Base.logger = @log
    ActiveRecord::Base.logger.level = Logger::DEBUG
  end

  after :each do
    ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
  end

  it 'should add to the default logger the shard name the query was sent to' do
    User.using(:canada).create!(:name => 'test')
    expect(@out.string).to match(/Shard: canada/)
  end

  describe '#with_connection' do
    before :each do
      Octoball.using(:canada) do
        @pool = ApplicationRecord.connection_pool
      end
      @pool.disconnect!
    end

    after :each do
      @pool.release_connection
      @pool.disconnect!
    end

    it 'should log the shard name for a new connection' do
      @pool.with_connection { |connection| connection.execute('SELECT 1') }

      expect(@out.string).to match(/\[Shard: canada\].*SELECT 1/)
    end

    it 'should log the shard name for an existing connection' do
      @pool.lease_connection.current_shard = nil
      @pool.with_connection { |connection| connection.execute('SELECT 1') }

      expect(@out.string).to match(/\[Shard: canada\].*SELECT 1/)
    end
  end
end
