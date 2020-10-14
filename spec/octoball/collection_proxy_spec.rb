require 'spec_helper'

describe Octoball do
  describe 'method dispatch' do
    before :each do
      @client = Client.using(:canada).create!
      @client.items << Item.using(:canada).create!
      @client.reload
    end

    it 'computes the size of the collection without loading it' do
      expect(@client.items.size).to eq(1)

      expect(@client.items.loaded?).to be false
    end
  end
end
