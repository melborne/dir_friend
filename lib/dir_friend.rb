require "dir_friend/version"
require 'gviz'

module DirFriend
  class F
    include Comparable
    attr_reader :name, :path, :level, :stat
    def initialize(name, level:0)
      @path = File.expand_path(name)
      @name = File.basename(@path)
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
    def initialize(name='.', level:0, depth:Float::MAX.to_i)
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
      D.new path.sub(/\/[^\/]+$/, '')
    end

    def down(child=nil)
      unless child
        min = entries.select(&:directory?).min
        return min unless min
        child = min.name
      end
      D.new File.join(path, child)
    end

    def to_s
      "D: #{name}"
    end

    def to_dot()
      DirFriend::Graph.new(self).render()
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

  class Graph
    def initialize(dir)
      @dir = dir
    end

    def render()
      build_graph().to_s
    end

    def build_graph()
      dirs = [@dir] + @dir.select(&:directory?)
      gv = ::Gviz.new
      gv.graph do
        dirs.each do |d|
          d_id = d.path.to_id
          ent_ids = d.entries.map { |ent| ent.path.to_id }
          ent_names = d.entries.map(&:name)
          route d_id => ent_ids
          node d_id, label:d.name
          ent_ids.zip(ent_names).each { |id, n| node id, label:n }
        end
      end
      gv
    end
  end
end
