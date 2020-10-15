require 'spec_helper'

describe Octoball do
  it 'should allow nested queries' do
    @user1 = User.using(:brazil).create!(:name => 'Thiago P', :number => 3)
    @user2 = User.using(:brazil).create!(:name => 'Thiago', :number => 1)
    @user3 = User.using(:brazil).create!(:name => 'Thiago', :number => 2)

    expect(User.using(:brazil).where(:name => 'Thiago').where(:number => 4).order(:number).all).to eq([])
    expect(User.using(:brazil).where(:name => 'Thiago').using(:canada).where(:number => 2).using(:brazil).order(:number).all).to eq([@user3])
    expect(User.using(:brazil).where(:name => 'Thiago').using(:canada).where(:number => 4).using(:brazil).order(:number).all).to eq([])
  end

  context 'When array-like-selecting an item in a group' do
    before(:each) do
      User.using(:brazil).create!(:name => 'Evan', :number => 1)
      User.using(:brazil).create!(:name => 'Evan', :number => 2)
      User.using(:brazil).create!(:name => 'Evan', :number => 3)
      @evans = User.using(:brazil).where(:name => 'Evan')
    end

    it 'allows a block to select an item' do
      expect(@evans.select { |u| u.number == 2 }.first.number).to eq(2)
    end
  end

  context 'When selecting a field within a scope' do
    before(:each) do
      User.using(:brazil).create!(:name => 'Evan', :number => 4)
      @evan = User.using(:brazil).where(:name => 'Evan')
    end

    it 'allows single field selection' do
      expect(@evan.select('name').first.name).to eq('Evan')
    end

    it 'allows selection by array' do
      expect(@evan.select(['name']).first.name).to eq('Evan')
    end

    it 'allows multiple selection by string' do
      expect(@evan.select('id, name').first.id).to be_a(Fixnum)
    end

    it 'allows multiple selection by array' do
      expect(@evan.select(%w(id name)).first.id).to be_a(Fixnum)
    end

    it 'allows multiple selection by symbol' do
      expect(@evan.select(:id, :name).first.id).to be_a(Fixnum)
    end

    it 'allows multiple selection by string and symbol' do
      expect(@evan.select(:id, 'name').first.id).to be_a(Fixnum)
    end
  end

  it "should raise a exception when trying to send a query to a shard that don't exists" do
    expect { User.using(:dont_exists).all }.to raise_exception(ActiveRecord::ConnectionNotEstablished)
  end

  context "dup / clone" do
    before(:each) do
      User.using(:brazil).create!(:name => 'Thiago', :number => 1)
    end

    it "should change it's object id" do
      user = User.using(:brazil).where(id: 1)
      dupped_object = user.dup
      cloned_object = user.clone

      expect(dupped_object.object_id).not_to eq(user.object_id)
      expect(cloned_object.object_id).not_to eq(user.object_id)
    end
  end

  context 'When iterated with Enumerable methods' do
    before(:each) do
      User.using(:brazil).create!(:name => 'Evan', :number => 1)
      User.using(:brazil).create!(:name => 'Evan', :number => 2)
      User.using(:brazil).create!(:name => 'Evan', :number => 3)
      @evans = User.using(:brazil).where(:name => 'Evan')
    end

    it 'allows each method' do
      expect(@evans.each.count).to eq(3)
    end

    it 'allows each_with_index method' do
      expect(@evans.each_with_index.to_a.flatten.count).to eq(6)
    end

    it 'allows map method' do
      expect(@evans.map(&:number)).to eq([1, 2, 3])
    end
  end
end
