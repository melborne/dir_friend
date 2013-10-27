module DirFriend
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
