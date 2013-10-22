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

    describe '#<=>' do
      it 'returns a minimum file' do
        fs = %w(c.txt b.txt a.txt).map do |f|
          File.write(f, '')
          DirFriend::F.new f
        end
        expect(fs.min).to eq fs.last
      end
    end
  end

  describe DirFriend::D do
    before(:each) do
      %w(A A/D A/D/G).each { |d| Dir.mkdir d }
      %w(A/a A/b A/c A/D/e A/D/f A/D/G/h A/D/G/i).each { |f| File.write(f, '') }
      @d = DirFriend::D.new('A')
    end

    describe '.new' do
      it 'returns current directory without argument' do
        d = DirFriend::D.new
        expect(d.name).to eq 'dir_friend'
      end
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
        up = d.up
        expect(up).to eq @d
        expect(up.level).to eq 0
      end
    end

    describe '#down' do
      it 'returns a child directory object' do
        d = DirFriend::D.new('A/D')
        down = @d.down('D')
        expect(down).to eq d
        expect(down.level).to eq 0
      end

      it 'returns a child child directory object' do
        d = DirFriend::D.new('A/D/G')
        down = @d.down('D/G')
        expect(down).to eq d
        expect(down.level).to eq 0
      end

      it 'returns a minimum child when no argument supplied' do
        Dir.mkdir('A/C')
        d1 = DirFriend::D.new('A')
        d2 = DirFriend::D.new('A/C')
        down = d1.down
        expect(down).to eq d2
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
