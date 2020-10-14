require 'logger'

ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))

mysql_spec = {
  adapter:  'mysql2',
  host:     'localhost',
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
ActiveRecord::Base.establish_connection(
  ActiveRecord::Base.configurations.configs_for(env_name: "test").first)
