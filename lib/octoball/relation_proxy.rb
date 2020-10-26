# frozen_string_literal: true

class Octoball
  class RelationProxy < BasicObject
    attr_reader :current_shard

    def initialize(rel, shard)
      @rel = rel
      self.current_shard = shard
    end

    def current_shard=(shard)
      @current_shard = shard
      @rel.current_shard = shard unless @rel.is_a?(::Enumerator)
    end

    def using(shard)
      self.current_shard = shard
      self
    end

    def ar_relation
      @rel
    end

    def respond_to?(method, include_all = false)
      return true if method == :ar_relation
      @rel.respond_to?(method, include_all)
    end

    def respond_to_missing?(method, include_private)
      super || @res.respond_to?(method, include_private)
    end

    ENUM_METHODS = (::Enumerable.instance_methods - ::Object.instance_methods).reject do |m|
      ::ActiveRecord::Relation.instance_method(m).source_location rescue nil
    end + [:each, :map, :index_by]
    ENUM_WITH_BLOCK_METHODS = [:find, :select, :none?, :any?, :one?, :many?, :sum]

    def method_missing(method, *args, **kwargs, &block)
      # raise NoMethodError unless the method is defined in @rel
      return @rel.public_send(method, *args, **kwargs, &block) unless @rel.respond_to?(method)

      preamble = <<-EOS
        def #{method}(*margs, **mkwargs, &mblock)
          return @rel.#{method}(*margs, **mkwargs, &mblock) unless @current_shard
      EOS
      postamble = <<-EOS
          return ret unless ret.is_a?(::ActiveRecord::Relation) || ret.is_a?(::ActiveRecord::QueryMethods::WhereChain) || ret.is_a?(::Enumerator)
          ::Octoball::RelationProxy.new(ret, @current_shard)
        end
      EOS
      connected_to = '::ActiveRecord::Base.connected_to(role: ::Octoball.current_role, shard: @current_shard)'

      if ENUM_METHODS.include?(method)
        ::Octoball::RelationProxy.class_eval <<-EOS, __FILE__, __LINE__ - 1
          #{preamble}
          ret = #{connected_to} { @rel.to_a }.#{method}(*margs, **mkwargs, &mblock)
          #{postamble}
        EOS
      elsif ENUM_WITH_BLOCK_METHODS.include?(method)
        ::Octoball::RelationProxy.class_eval <<-EOS, __FILE__, __LINE__ - 1
          #{preamble}
          ret = nil
          if mblock
            ret = #{connected_to} { @rel.to_a }.#{method}(*margs, **mkwargs, &mblock)
          else
            #{connected_to} { ret = @rel.#{method}(*margs, **mkwargs, &mblock); nil } # return nil avoid loading relation
          end
          #{postamble}
        EOS
      else
        ::Octoball::RelationProxy.class_eval <<-EOS, __FILE__, __LINE__ - 1
          #{preamble}
          ret = nil
          #{connected_to} { ret = @rel.#{method}(*margs, **mkwargs, &mblock); nil } # return nil to avoid loading relation
          #{postamble}
        EOS
      end

      public_send(method, *args, **kwargs, &block)
    end

    def inspect
      return @rel.inspect unless @current_shard
      ::ActiveRecord::Base.connected_to(shard: @current_shard, role: ::Octoball.current_role) { @rel.inspect }
    end

    def ==(obj)
      return false if obj.respond_to?(:current_shard) && obj.current_shard != @current_shard
      return @rel == obj unless @current_shard
      ::ActiveRecord::Base.connected_to(shard: @current_shard, role: ::Octoball.current_role) { @rel == obj }
    end

    def ===(obj)
      return false if obj.respond_to?(:current_shard) && obj.current_shard != @current_shard
      return @rel === obj unless @current_shard
      ::ActiveRecord::Base.connected_to(shard: @current_shard, role: ::Octoball.current_role) { @rel === obj }
    end
  end
end
