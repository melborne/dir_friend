require 'thor'
require 'yaml'

module DirFriend
  class Command < Thor
    include Thor::Actions

    desc "info PATH", "Show PATH info"
    def info(path)
      puts Any.new(path).info
    end

    desc "dot PATH", "Create a graphviz dot file for PATH"
    long_desc ~<<-EOS
      ex.

        `dir_friend dot path/ -l fdp -c blues, -e "arrowhead:none"`

        `dir_friend dot path/ -c greens -g "bgcolor:azure,rankdir:LR,splines:ortho"`
    EOS
    option :layout, aliases:"-l"
    option :colorscheme, aliases:"-c"
    option :dir_shape
    option :file_shape
    option :global, aliases:"-g"
    option :nodes, aliases:"-n"
    option :edges, aliases:"-e"
    option :save, aliases:"-s", default:'a', desc:"Save filename"
    option :depth, aliases:"-d", default:9
    option :with_open, aliases:"-o", default: true, type: :boolean
    option :theme, aliases:"-t"
    option :exclude, aliases:"-x", desc:"Specify directories for exclude with comma separated values"
    def dot(path)
      opt = options.to_keysym_hash
      save_path = opt.delete(:save)
      exclude = (ex=opt.delete(:exclude)) ? ex.split(',') : []
      opt = opt_parser(opt)

      dir = D.new(path, depth:options[:depth].to_i, exclude:exclude)
      dir.to_dot(opt).save(save_path)
      puts "'#{save_path}.dot' created in the current directory."

      if options[:with_open] && OS.mac?
        run(%Q{open "#{save_path}.dot"}, verbose: false)
      end
    end

    desc "version", "Show DirFriend version"
    def version
      puts "DirFriend #{DirFriend::VERSION} (c) 2013 kyoendo"
    end
    map "-v" => :version

    desc "banner", "Describe DirFriend usage", hide:true
    def banner
      banner = <<-EOS
DirFriend is a tool for visualizing file directory.
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
        if Config.enable
          theme = Config.read(opt.delete(:theme))
          theme.merge(opt)
        else
          opt
        end
      end
    end
  end
end
