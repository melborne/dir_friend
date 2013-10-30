module DirFriend
  class Config
    CONFIG_PATH = File.join(ENV['HOME'], '.dirfriend/config.yaml')
    CONFIG_FILE = File.basename(CONFIG_PATH)
    def self.read(theme)
      new.read(theme)
    end

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
      puts "'#{CONFIG_FILE}' not found."
      {}
    rescue Psych::SyntaxError
      abort "Syntax errors found in your '#{CONFIG_FILE}'."
    end

    private
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
