
module DirFriend
  class Config
    CONFIG_PATH = File.join(ENV['HOME'], '.dirfriend/config.yaml')
    CONFIG_FILE = File.basename(CONFIG_PATH)
    class << self
      def read(theme)
        new.read(theme)
      end
      attr_accessor :enable
    end
    self.enable = true

    def read(theme)
      if theme
        use_passed_theme(theme)
      else
        use_default_theme
      end
    end

    def themes
      @themes ||= YAML.load_file(CONFIG_PATH).to_keysym_hash
    rescue Errno::ENOENT
      create
      {}
    rescue Psych::SyntaxError => e
      abort "Syntax errors found in your '#{CONFIG_FILE}': #{e}."
    end

    private
    def create
      dir = File.dirname(CONFIG_PATH)
      Dir.mkdir(dir) unless Dir.exist?(dir)
      FileUtils.copy(template, CONFIG_PATH)
      puts "'#{CONFIG_FILE}' created in #{dir}"
    rescue => e
      abort "Something go wrong: #{e}"
    end

    def template
      File.join(__dir__, 'template.yaml')
    end

    def use_passed_theme(theme)
      themes[theme.intern].tap do |tm|
        abort "Theme: '#{theme}' not found in your #{CONFIG_FILE}" unless tm
      end
    end

    def use_default_theme
      case defo = themes.delete(:default)
      when Symbol, String
        themes[defo.intern] || {}
      when Hash
        defo
      else
        {}
      end
    end
  end
end
