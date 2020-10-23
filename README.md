# Octoball - Octopus-like sharding helper library for ActiveRecord 6.1+

Octoball provides [Octopus](https://github.com/thiagopradi/octopus)-like database sharding helpers for ActiveRecord 6.1+.
This will make it easier to upgrade Rails to 6.1+ for applications using [Octopus gem](https://github.com/thiagopradi/octopus) for database sharding with Rails 4.x/5.x.

Currently, its implementation is focusing on horizontal database sharding. However, by customizing shard key mapping, it can be applied to replication use case too.

## Scope of this gem

### What is included in Octoball
- Octopus-like shard swithcing by `using` class method, e.g.:
  ```ruby
  Octoball.using(:shard1) { User.find_by_name("Alice") }
  User.using(:shard1).first
  ```
- Each model instance knows which shard it came from so shard will be switched automatically:
  ```ruby
  user1 = User.using(:shard1).find_by_name("Bob")
  user2 = User.using(:shard2).find_by_name("Charlie")
  user1.age += 1
  user2.age += 1
  user1.save!  #  Save the user1 in the correct shard `:shard1`
  user2.save!  #  Save the user2 in the correct shard `:shard2`
  ```
- Relations such as `has_many` are also resolved from the model instance's shard:
  ```ruby
  user = User.using(:shard1).find_by_name("Alice")
  user.blogs.where(title: "blog")  # user's blogs are fetched from `:shard1`
  ```

### What is NOT included in Octoball
- Connection handling and configuration -- managed by the native `ActiveRecord::Base.connects_to` methods introduced in ActiveRecord 6.1.
  - You need to migrate from Octopus' `config/shards.yml` to [Rails native multiple DB configuration using `config/database.yml`](https://edgeguides.rubyonrails.org/active_record_multiple_databases.html). Please refer the [Setup](#Setup) section for more details.
- Migration -- done by ActiveRecord 6.1+ natively.
  - Instead of `using` method in Octopus, you can specify the `migrations_paths` parameter in the `config/database.yml` file.
- Replication handling -- done by ActiveRecord's `role`
  - round-robin connection scheduler is currently omitted.

## Setup

```
gem "octoball"
```
Define the database connections in `config/database.yml`, e.g.:
```
default: &default
  adapter: mysql2
  pool: 5
  username: root
  host: localhost
  timeout: 5000
  connnect_timeout: 5000

development:
  primary:
    <<: *default
    database: db_primary
  shard1_connection:
    <<: *default
    database: db_shard1
```
And define shards and corresponding connections in abstract ActiveRecord model class, e.g.:
```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to shards: {
    default: { writing: :primary },
    shard1: { writing: :shard1_connection },
  }
end

class User < ApplicationRecord
  ...
end
```

## Development of Octoball
Octoball has rspec tests delived from subsets of Octopus' rspec.

To run the rspec tests, follow these steps:
```
RAILS_ENV=test bundle exec rake db:prepare
RAILS_ENV=test bundle exec rake
```

## License
Octoball is released under the MIT license.

Original Octopus' copyright: Copyright (c) Thiago Pradi
