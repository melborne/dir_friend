require 'thor'

module DirFriend
  class Command < Thor
    
    desc "info DIR", "Show DIR info"
    def info(path)
      puts Any.new(path).info
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
  end
end