require './spec/models/application_record.rb'

# The user class is just sharded, not replicated
class User < ApplicationRecord
  scope :thiago, -> { where(:name => 'Thiago') }

  def awesome_queries
    Octoball.using(:canada) do
      User.create(:name => 'teste')
    end
  end
end

# The client class isn't replicated
class Client < ApplicationRecord
  has_many :items
  has_many :comments, :as => :commentable
end

# This class sets its own connection
class CustomConnectionBase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(:adapter => 'mysql2', :host => (ENV['MYSQL_HOST'] || 'localhost'), :database => 'octoball_shard_2', :username => "#{ENV['MYSQL_USER'] || 'root'}", :password => '')
  connects_to shards: {
    custom_shard: { writing: :shard3 }
  }
end

class CustomConnection < CustomConnectionBase
  self.table_name = 'custom'
end

# This items belongs to a client
class Item < ApplicationRecord
  belongs_to :client
  has_many :parts
end

class Part < ApplicationRecord
  belongs_to :item
end

class Keyboard < ApplicationRecord
  validates_uniqueness_of(:name, case_sensitive: true)
  belongs_to :computer
end

class Computer < ApplicationRecord
  has_one :keyboard
end

class Role < ApplicationRecord
  has_and_belongs_to_many :permissions
end

class Permission < ApplicationRecord
  has_and_belongs_to_many :roles
end

class Assignment < ApplicationRecord
  belongs_to :programmer
  belongs_to :project
end

class Programmer < ApplicationRecord
  has_many :assignments
  has_many :projects, :through => :assignments
end

class Project < ApplicationRecord
  has_many :assignments
  has_many :programmers, :through => :assignments
end

class Comment < ApplicationRecord
  belongs_to :commentable, :polymorphic => true
  scope :open, -> { where(open: true) }
end

class Bacon < ApplicationRecord
  self.table_name = 'yummy'
end

class Cheese < ApplicationRecord
  self.table_name = 'yummy'
end

class Ham < ApplicationRecord
  self.table_name = 'yummy'
end

# This class sets its own connection
class Advert < ApplicationRecord
end

class MmorpgPlayer < ApplicationRecord
  has_many :weapons
  has_many :skills
end

class Weapon < ApplicationRecord
  belongs_to :mmorpg_player, :inverse_of => :weapons
  validates :hand, :uniqueness => { :scope => :mmorpg_player_id }
  validates_presence_of :mmorpg_player
  has_many :skills
end

class Skill < ApplicationRecord
  belongs_to :weapon, :inverse_of => :skills
  belongs_to :mmorpg_player, :inverse_of => :skills

  validates_presence_of :weapon
  validates_presence_of :mmorpg_player
  validates :name, :uniqueness => { :scope => :mmorpg_player_id }
end
