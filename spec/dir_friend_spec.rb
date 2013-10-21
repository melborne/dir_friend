require 'spec_helper'
require 'fakefs/spec_helpers'

describe DirFriend do
  include FakeFS::SpecHelpers
  it 'should have a version number' do
    DirFriend::VERSION.should_not be_nil
  end

  describe DirFriend::F do
    before(:each) do
      File.write('foo.txt', '')
      @f = DirFriend::F.new('foo.txt')
    end

    describe '#path' do
      it 'returns a file path' do
        path = File.expand_path('foo.txt')
        expect(@f.path).to eq path
      end
    end
  end
end
