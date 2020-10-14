# frozen_string_literal: true

require 'active_record'
require 'octoball/version'
require 'octoball/relation_proxy'
require 'octoball/connection_adapters'
require 'octoball/current_shard_tracker'
require 'octoball/association'
require 'octoball/association_shard_check'
require 'octoball/persistence'

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
