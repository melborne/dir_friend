require 'thor'

module DirFriend
  class Command < Thor
    
    desc "info PATH", "Show PATH info"
    def info(path)
      puts Any.new(path).info
    end

    desc "dot PATH", "Build & Save a graphviz dot file"
    option :layout, aliases:"-l"
    option :colorscheme, aliases:"-c"
    option :dir_shape
    option :file_shape
    option :global, aliases:"-g"
    option :nodes, aliases:"-n"
    option :edges, aliases:"-e"
    option :save, aliases:"-s", default:'a'
    option :depth, aliases:"-d", default:9
    def dot(path)
      opt = options.dup.inject({}) { |h, (k,v)| h[k.intern] = v; h  }
      save_path = opt.delete(:save)
      opt = opt_parser(opt)
      dir = D.new(path, depth:options[:depth].to_i)
      dir.to_dot(opt).save(save_path)
      puts "Dot file created: `#{save_path}.dot`"
    end

    desc "version", "Show DirFriend version"
    def version
      puts "DirFriend #{DirFriend::VERSION} (c) 2013 kyoendo"
    end
    map "-v" => :version

    desc "banner", "Describe DirFriend usage", hide:true
    def banner
      banner = <<-EOS
DirFriend is a friend of file directory.
      EOS
      puts banner
      help
    end
    default_task :banner
    map "-h" => :banner

    no_commands do
      def opt_parser(opt)
        %i(global nodes edges).each do |attr|
          if kv = opt.delete(attr)
            kv_arr = kv.split(/\s*,\s*/)
                       .map{ |kv| kv.split(/\s*:\s*/).map(&:strip) }
                       .map{ |k, v| [k.intern, v] }
            opt.update({attr => Hash[ kv_arr ]})
          end
        end
        opt
      end
    end
  end
end