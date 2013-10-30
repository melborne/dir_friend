module HashExtension
  def to_keysym_hash
    self.inject({}) do |h, (k, v)|
      h[k.intern] = begin
        case v
        when Hash then v.to_keysym_hash
        else v
        end
      end
      h
    end
  end
end

Hash.send(:include, HashExtension)
