require 'rbconfig'

module DirFriend
  class OS
    def self.mac?
      RbConfig::CONFIG['host_os'].match /mac|darwin/
    end
  end

  class D < F
    include Enumerable
    attr_reader :entries
    def initialize(name='.', level:0, depth:Float::MAX.to_i, exclude:[])
      super(name, level:level)
      @entries = []
      @exclude = exclude
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

    def depth
      @depth ||= map(&:level).max
    end

    def to_s
      "D: #{name}"
    end

    def to_dot(opt={})
      graph = DirFriend::Graph.new(self)
      if opt.delete(:open) && OS.mac?
        Tempfile.open(['dirfriend', '.dot']) do |f|
          f.puts graph.build(opt)
          if system("open", f.path)
            puts "Graphviz opened tempfile: #{f.path}"
          end
        end
      else
        graph.build(opt)
      end
    rescue
      abort "something go wrong."
    end

    private
    def build(depth)
      entries = Dir[File.join(path, '*')]
      entries.each do |ent|
        next if @exclude.include?(ent)
        @entries << Any.new(ent, level:level+1, depth:depth-1, exclude:@exclude)
      end
    end
  end
end
