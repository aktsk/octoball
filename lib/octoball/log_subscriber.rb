# Implementation courtesy of db-charmer.
class Octoball
  module LogSubscriber
    attr_accessor :current_shard

    def sql(event)
      shard = event.payload[:connection]&.current_shard
      self.current_shard = shard == ActiveRecord::Base.default_shard ? nil : shard
      super
    end

    private

    def debug(progname = nil, &block)
      conn = current_shard ? color("[Shard: #{current_shard}]", ActiveSupport::LogSubscriber::GREEN, true) : ''
      super(conn + progname.to_s, &block)
    end
  end
end

ActiveRecord::LogSubscriber.prepend(Octoball::LogSubscriber)
