# frozen_string_literal: true

class Octoball
  module RelationCurrentShard
    attr_accessor :current_shard
  end

  module ShardedCollectionAssociation
    [:reader, :writer, :ids_reader, :ids_writer, :create, :create!,
     :build, :include?, :load_target, :reload, :size, :select].each do |method|
      class_eval <<-"END", __FILE__, __LINE__ + 1
        def #{method}(*args, **kwargs, &block)
          shard = owner.current_shard
          return super if !shard || shard == ActiveRecord::Base.default_shard
          ActiveRecord::Base.connected_to(shard: shard, role: Octoball.current_role) do
            ret = super
            return ret unless ret.is_a?(::ActiveRecord::Relation) || ret.is_a?(::ActiveRecord::QueryMethods::WhereChain)
            RelationProxy.new(ret, shard)
          end
        end
      END
    end
  end

  module ShardedCollectionProxy
    [:any?, :build, :count, :create, :create!, :concat, :delete, :delete_all,
     :destroy, :destroy_all, :empty?, :find, :first, :include?, :last, :length,
     :many?, :pluck, :replace, :select, :size, :sum, :to_a, :uniq].each do |method|
      class_eval <<-"END", __FILE__, __LINE__ + 1
        def #{method}(*args, **kwargs, &block)
          return super if !@association.owner.current_shard || @association.owner.current_shard == ActiveRecord::Base.default_shard
          ActiveRecord::Base.connected_to(shard: @association.owner.current_shard, role: Octoball.current_role) do
            super
          end
        end
      END
    end
  end

  module ShardedSingularAssociation
    [:reader, :writer, :create, :create!, :build].each do |method|
      class_eval <<-"END", __FILE__, __LINE__ + 1
        def #{method}(*args, **kwargs, &block)
          return super if !owner.current_shard || owner.current_shard == ActiveRecord::Base.default_shard
          ActiveRecord::Base.connected_to(shard: owner.current_shard, role: Octoball.current_role) do
            super
          end
        end
      END
    end
  end

  ::ActiveRecord::Relation.prepend(RelationCurrentShard)
  ::ActiveRecord::QueryMethods::WhereChain.prepend(RelationCurrentShard)
  ::ActiveRecord::Associations::CollectionAssociation.prepend(ShardedCollectionAssociation)
  ::ActiveRecord::Associations::CollectionProxy.prepend(ShardedCollectionProxy)
  ::ActiveRecord::Associations::SingularAssociation.prepend(ShardedSingularAssociation)
end
