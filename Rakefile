# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new
RuboCop::RakeTask.new

namespace :db do
  mysql_spec = {
    adapter:  'trilogy',
    host:     (ENV['MYSQL_HOST'] || '127.0.0.1'),
    username: (ENV['MYSQL_USER'] || 'root'),
    port:     (ENV['MYSQL_PORT'] || 3306),
    encoding: 'utf8mb4',
  }

  desc 'Build the databases for tests'
  task :build_databases do
    require 'active_record'

    # Connect to MYSQL
    ActiveRecord::Base.establish_connection(mysql_spec)
    (1..5).map do |i|
      # drop the old database (if it exists)
      ActiveRecord::Base.connection.drop_database("octoball_shard_#{i}")
      # create new database
      ActiveRecord::Base.connection.create_database("octoball_shard_#{i}", charset: 'utf8mb4')
    end
  end

  desc 'Create tables on tests databases'
  task :create_tables do
    require 'active_record'

    ActiveRecord::Base.configurations = {
      "test" => {
        shard1: mysql_spec.merge(database: 'octoball_shard_1'),
        shard2: mysql_spec.merge(database: 'octoball_shard_2'),
        shard3: mysql_spec.merge(database: 'octoball_shard_3'),
        shard4: mysql_spec.merge(database: 'octoball_shard_4'),
        shard5: mysql_spec.merge(database: 'octoball_shard_5'),
      }
    }
    require './spec/models/application_record'
    ActiveRecord::Base.configurations.configs_for(env_name: "test").each do |config|
      ActiveRecord::Base.establish_connection(config)
      schema_migration = if ActiveRecord.gem_version >= Gem::Version.new(7.2)
                           ActiveRecord::Base.connection.pool.schema_migration
                         else
                           ActiveRecord::Base.connection.schema_migration
                         end
      ActiveRecord::MigrationContext.new("spec/migration", schema_migration)
        .migrate(config.database == 'octoball_shard_5' ? 2 : 1)
    end
  end

  desc 'Prepare the test databases'
  task prepare: [:build_databases, :create_tables]
end
