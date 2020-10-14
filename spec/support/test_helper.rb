module TestHelper
  def self.clean_all_shards(shards)
    (shards || [:master, :brazil, :canada, :russia, :alone_shard]).each do |shard_symbol|
      %w(users clients cats items keyboards computers permissions_roles roles permissions assignments projects programmers yummy adverts).each do |tables|
        ApplicationRecord.using(shard_symbol).connection.execute("DELETE FROM #{tables}")
      end
      if shard_symbol == :alone_shard
        %w(mmorpg_players weapons skills).each do |table|
          ApplicationRecord.using(shard_symbol).connection.execute("DELETE FROM #{table}")
        end
      end
    end
  end
end
