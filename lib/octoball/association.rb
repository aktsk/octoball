# frozen_string_literal: true

class Octoball
  module RelationCurrentShard
    attr_accessor :current_shard
  end

  module RelationProxyIsARelation
    def ===(other)
      other.is_a?(self)
    end
  end

  module ShardedCollectionAssociation
    [:writer, :ids_reader, :ids_writer, :create, :create!,
     :build, :include?, :load_target, :reload, :size, :select].each do |method|
      class_eval <<-"END", __FILE__, __LINE__ + 1
        def #{method}(*args, **kwargs, &block)
          shard = owner.current_shard
          return super(*args, **kwargs, &block) if !shard || shard == ActiveRecord::Base.current_shard
          ret = nil
          ActiveRecord::Base.connected_to(shard: shard, role: Octoball.current_role) do
            ret = super(*args, **kwargs, &block)
            return ret unless ret.is_a?(::ActiveRecord::Relation) || ret.is_a?(::ActiveRecord::QueryMethods::WhereChain)
            ret = RelationProxy.new(ret, shard)
            nil # return nil to avoid loading relation
          end
          ret
        end
      END
    end
  end

  module ShardedCollectionProxyCreate
    def create(klass, association)
      shard = association.owner.current_shard
      return super unless shard
      return RelationProxy.new(super, shard) if shard == ActiveRecord::Base.current_shard
      ret = nil
      ActiveRecord::Base.connected_to(shard: shard, role: Octoball.current_role) do
        ret = RelationProxy.new(super, shard)
        nil # return nil to avoid loading relation
      end
      ret
    end
  end

  module ShardedCollectionProxy
    [:any?, :build, :count, :create, :create!, :concat, :delete, :delete_all,
     :destroy, :destroy_all, :empty?, :find, :first, :include?, :last, :length,
     :many?, :pluck, :replace, :select, :size, :sum, :to_a, :uniq].each do |method|
      class_eval <<-"END", __FILE__, __LINE__ + 1
        def #{method}(*args, **kwargs, &block)
          return super(*args, **kwargs, &block) if !@association.owner.current_shard || @association.owner.current_shard == ActiveRecord::Base.current_shard
          ActiveRecord::Base.connected_to(shard: @association.owner.current_shard, role: Octoball.current_role) do
            super(*args, **kwargs, &block)
          end
        end
      END
    end
  end

  module ShardedSingularAssociation
    [:reload, :writer, :create, :create!, :build].each do |method|
      class_eval <<-"END", __FILE__, __LINE__ + 1
        def #{method}(*args, **kwargs, &block)
          return super(*args, **kwargs, &block) if !owner.current_shard || owner.current_shard == ActiveRecord::Base.current_shard
          ActiveRecord::Base.connected_to(shard: owner.current_shard, role: Octoball.current_role) do
            super(*args, **kwargs, &block)
          end
        end
      END
    end
  end

  ::ActiveRecord::Relation.prepend(RelationCurrentShard)
  ::ActiveRecord::Relation.singleton_class.prepend(RelationProxyIsARelation)
  ::ActiveRecord::QueryMethods::WhereChain.prepend(RelationCurrentShard)
  ::ActiveRecord::Associations::CollectionAssociation.prepend(ShardedCollectionAssociation)
  ::ActiveRecord::Associations::CollectionProxy.singleton_class.prepend(ShardedCollectionProxyCreate)
  ::ActiveRecord::Associations::CollectionProxy.prepend(ShardedCollectionProxy)
  ::ActiveRecord::Associations::SingularAssociation.prepend(ShardedSingularAssociation)
end
