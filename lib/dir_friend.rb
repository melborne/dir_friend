require "dir_friend/version"

module DirFriend
  class F
    include Comparable
    attr_reader :name, :path, :level, :stat
    def initialize(name, level:0)
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

    def ==(other)
      self.path == other.path
    end
    alias :eql? :==

    def <=>(other)
      self.name <=> other.name
    end

    def to_s
      "F: #{name}"
    end
  end

  class D < F
    include Enumerable
    attr_reader :entries
    def initialize(name, level:0, depth:Float::MAX.to_i)
      super(name, level:level)
      @entries = []
      build(depth) if depth >= 1
      self
    end

    def each(&blk)
      entries.each do |e|
        blk.call(e)
        e.each(&blk) if e.is_a?(D)
      end
    end

    def info
      dirs, files = group_by { |f| f.is_a? D }.map { |_, fs| fs.size }
      depth = map(&:level).max
      {directories: dirs, files: files, depth: depth}
    end

    def up
      D.new path.sub(/\/[^\/]+$/, ''), level:level-1
    end

    def down(child=nil)
      child ||= entries.select(&:directory?).min.name
      lv = child.scan(/\/[^\/]+/).size + 1
      D.new File.join(path, child), level:level+lv
    end

    def to_s
      "D: #{name}"
    end

    private
    def build(depth)
      entries = Dir[File.join(path, '*')]
      entries.each do |ent|
        @entries << Any.new(ent, level:level+1, depth:depth-1)
      end
    end
  end

  class Any
    def self.new(f, level:0, depth:Float::MAX.to_i)
      if File.directory?(f)
        D.new(f, level:level, depth:depth)
      else
        F.new(f, level:level)
      end
    end
  end
end
