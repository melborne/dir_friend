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

    def info
      format = %i(mode nlink uid gid size mtime)
      arr = format.map { |attr| [attr, stat.send(attr)] }
      Hash[ arr ]
    end

    def to_s
      "F: #{name}"
    end
  end
end
