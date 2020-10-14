class TestTables < ActiveRecord::Migration[6.1]
  def change
    create_table(:users) do |u|
      u.string :name
      u.integer :number
      u.boolean :admin
      u.datetime :created_at
      u.datetime :updated_at
    end

    create_table(:clients) do |u|
      u.string :country
      u.string :name
    end

    create_table(:cats) do |u|
      u.string :name
    end

    create_table(:items) do |u|
      u.string :name
      u.integer :client_id
    end

    create_table(:computers) do |u|
      u.string :name
    end

    create_table(:keyboards) do |u|
      u.string :name
      u.integer :computer_id
    end

    create_table(:roles) do |u|
      u.string :name
    end

    create_table(:permissions) do |u|
      u.string :name
    end

    create_table(:permissions_roles, :id => false) do |u|
      u.integer :role_id
      u.integer :permission_id
    end

    create_table(:assignments) do |u|
      u.integer :programmer_id
      u.integer :project_id
    end

    create_table(:programmers) do |u|
      u.string :name
    end

    create_table(:projects) do |u|
      u.string :name
    end

    create_table(:comments) do |u|
      u.string :name
      u.string :commentable_type
      u.integer :commentable_id
      u.boolean :open, default: false
    end

    create_table(:parts) do |u|
      u.string :name
      u.integer :item_id
    end

    create_table(:yummy) do |u|
      u.string :name
    end

    create_table(:adverts) do |u|
      u.string :name
    end

    create_table(:custom) do |u|
      u.string :value
    end
  end
end
