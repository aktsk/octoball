class AloneShardTables < ActiveRecord::Migration[6.1]
  def change
    create_table(:mmorpg_players) do |u|
      u.string :player_name
    end

    create_table(:weapons) do |u|
      u.integer :mmorpg_player_id
      u.string :name
      u.string :hand
    end

    create_table(:skills) do |u|
      u.integer :mmorpg_player_id
      u.integer :weapon_id
      u.string :name
    end
  end
end
