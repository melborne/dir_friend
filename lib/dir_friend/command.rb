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
    long_desc <<-EOS
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
    option :save, aliases:"-s", default:'a'
    option :depth, aliases:"-d", default:9
    option :with_open, aliases:"-o", default: true, type: :boolean
    option :theme, aliases:"-t"
    def dot(path)
      opt = key_symbolize(options)
      save_path = opt.delete(:save)
      opt = opt_parser(opt)

      dir = D.new(path, depth:options[:depth].to_i)
      dir.to_dot(opt).save(save_path)
      puts "Dot file created: `#{save_path}.dot`"

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
        theme = read_config(opt.delete(:theme))
        theme.merge(opt)
      end


      def key_symbolize(hash)
        return hash unless hash.is_a?(Hash)
        hash.inject({}) do |h, (k, v)|
          h[k.intern] = key_symbolize(v)
          h
        end
      end

      def read_config(theme)
        themes = YAML.load_file(File.join ENV['HOME'], '.dirfriend/config.yaml')
        themes = key_symbolize(themes)
        if theme
          if tm = themes[theme.intern]
            return tm
          else
            abort "Theme: '#{theme}' not found in your config.yaml"
          end
        end

        case defo = themes.delete(:default)
        when Symbol, String
          themes[defo.intern] || {}
        when Hash
          defo
        else
          {}
        end
      rescue Errno::ENOENT
        puts 'config.yaml not found.'
        {}
      rescue Psych::SyntaxError
        abort 'some syntax errors found in your config.yaml.'
      end
    end
  end
end
