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

    describe '#stat' do
      it 'returns File::Stat object' do
        expect(@f.stat).to be_instance_of(File::Stat)
      end
    end

    describe '#method_missing' do
      it 'returns instance methods of File::Stat' do
        f = File::Stat.new('foo.txt')
        expect(@f.size).to eq f.size
        expect(@f.directory?).to eq f.directory?
        expect(@f.atime).to eq f.atime
      end
    end
  end

  describe DirFriend::D do
    before(:each) do
      %w(A A/D A/D/G).each { |d| Dir.mkdir d }
      %w(A/a A/b A/c A/D/e A/D/f A/D/G/h A/D/G/i).each { |f| File.write(f, '') }
      @d = DirFriend::D.new('A')
    end

    describe '#entries' do
      it 'returns entries in directory' do
        expect(@d.entries.map(&:name).sort).to eq %w(D a b c)
      end
    end

    describe '#each' do
      it 'iterates whole files in directory' do
        ent = @d.map(&:name).sort
        expect(ent).to eq %w(D G a b c e f h i)
      end
    end
  end
end
