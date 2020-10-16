require 'spec_helper'

describe Octoball::LogSubscriber, :shards => [:canada] do
  before :each do
    @out = StringIO.new
    @log = Logger.new(@out)
    ActiveRecord::Base.logger = @log
    ActiveRecord::Base.logger.level = Logger::DEBUG
  end

  after :each do
    ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
  end

  it 'should add to the default logger the shard name the query was sent to' do
    User.using(:canada).create!(:name => 'test')
    expect(@out.string).to match(/Shard: canada/)
  end
end
