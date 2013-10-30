module DirFriend
  class Config
    CONFIG_PATH = File.join(ENV['HOME'], '.dirfriend/config.yaml')
    CONFIG_FILE = File.basename(CONFIG_PATH)

    def self.build(theme)
      themes = YAML.load_file(CONFIG_PATH).to_keysym_hash
      if theme
        use_passed_theme(theme)
      else
        use_default_theme
      end
    rescue Errno::ENOENT
      puts "'#{CONFIG_FILE}' not found."
      {}
    rescue Psych::SyntaxError
      abort "Syntax errors found in your '#{CONFIG_FILE}'."
    end

    def self.use_passed_theme(theme)
      themes[theme.intern].tap do |tm|
        abort "Theme: '#{theme}' not found in your #{CONFIG_FILE}" unless tm
      end
    end

    def self.use_default_theme(themes)
      case defo = themes.delete(:default)
      when Symbol, String
        themes[defo.intern] || {}
      when Hash
        defo
      else
        {}
      end
    end

    private_class_method :use_default_theme, :use_passed_theme
  end
end
