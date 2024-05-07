class Octoball
  def self.using(shard, &block)
    ActiveRecord::Base.connected_to(role: current_role, shard: shard&.to_sym, &block)
  end

  def self.current_role
    ActiveRecord::Base.current_role || ActiveRecord::Base.writing_role
  end

  module UsingShard
    def using(shard)
      Octoball::RelationProxy.new(all, shard&.to_sym)
    end
  end

  ::ActiveRecord::Base.singleton_class.prepend(UsingShard)
end
