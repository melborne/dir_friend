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

    describe '#info' do
      it 'returns numbers of files and directories in the directory' do
        info = {directories: 2, files: 7, depth: 3}
        expect(@d.info).to eq info
      end
    end

    describe '#up' do
      it 'returns a parent directory object' do
        d = DirFriend::D.new('A/D')
        expect(d.up.name).to eq @d.name
        expect(d.up.path).to eq @d.path
      end
    end
  end

  describe DirFriend::Any do
    before(:each) do
      %w(A A/D A/D/G).each { |d| Dir.mkdir d }
      %w(A/a A/b A/c A/D/e A/D/f A/D/G/h A/D/G/i).each { |f| File.write(f, '') }
    end

    describe '.new' do
      it 'returns a F object when the arg is a file' do
        any = DirFriend::Any.new('A/a')
        expect(any).to be_instance_of(DirFriend::F)
      end

      it 'returns a D object when the arg is a directory' do
        any = DirFriend::Any.new('A')
        expect(any).to be_instance_of(DirFriend::D)
      end
    end
  end
end
