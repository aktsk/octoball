require 'rubygems'
require 'bundler/setup'
require 'octoball'

Octoball.instance_variable_set(:@directory, File.dirname(__FILE__))

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  mysql_spec = {
    adapter:  'mysql2',
    host:     (ENV['MYSQL_HOST'] || 'localhost'),
    username: (ENV['MYSQL_USER'] || 'root'),
    encoding: 'utf8mb4',
  }
  ActiveRecord::Base.configurations = {
    "test" => {
      shard1: mysql_spec.merge(database: 'octoball_shard_1'),
      shard2: mysql_spec.merge(database: 'octoball_shard_2'),
      shard3: mysql_spec.merge(database: 'octoball_shard_3'),
      shard4: mysql_spec.merge(database: 'octoball_shard_4'),
      shard5: mysql_spec.merge(database: 'octoball_shard_5'),
    }
  }

  config.before(:each) do |example|
    TestHelper.clean_all_shards(example.metadata[:shards])
  end
end
