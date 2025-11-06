# frozen_string_literal: true

require 'active_record'
require 'octoball/version'

ActiveSupport.on_load(:active_record) do
  require 'octoball/relation_proxy'
  require 'octoball/connection_adapters'
  require 'octoball/current_shard_tracker'
  require 'octoball/association_shard_check'
  require 'octoball/persistence'
  require 'octoball/association'
  require 'octoball/log_subscriber'
  require 'octoball/using_shard'
end
