# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to shards: {
    master:      { writing: :shard1 },
    brazil:      { writing: :shard2 },
    canada:      { writing: :shard3 },
    russia:      { writing: :shard4 },
    alone_shard: { writing: :shard5 },
  }
end
