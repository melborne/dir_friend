require "dir_friend/version"

module DirFriend
  class F
    attr_reader :name, :path, :level, :stat
    def initialize(name, level=0)
      @name = File.basename(name)
      @path = File.expand_path(name)
      @stat = File.stat(@path)
      @level = level
    end

    def method_missing(name, *a, &b)
      stat_methods = stat.class.instance_methods(false)
      return super unless stat_methods.include?(name)
      stat.__send__(name)
    end

    def to_s
      "F: #{name}"
    end
  end

  class D < F
    include Enumerable
    attr_reader :entries
    def initialize(name, level=0, depth=Float::MAX.to_i)
      super(name, level)
      @entries = []
      build(depth) if depth >= 1
      self
    end

    def <<(file)
      @entries << file
    end

    def each(&blk)
      entries.each do |e|
        blk.call(e)
        e.each(&blk) if e.is_a?(D)
      end
    end

    def to_s
      "D: #{name} => [#{entries.join(', ')}]"
    end

    private
    def build(depth)
      entries = Dir[File.join(path, '*')]
      entries.each do |ent|
        self << begin
          File.directory?(ent) ? D.new(ent, level+1, depth-1) : F.new(ent, level+1)
        end
      end
    end
  end
end
