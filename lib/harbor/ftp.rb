lib = (Pathname(__FILE__).dirname.parent).to_s
$:.unshift lib unless $:.include?(lib)

require "java"

require "rjack-logback"
RJack::Logback.config_console( :level => :debug )

Dir[Pathname(__FILE__).dirname.parent.parent + "jars" + "*.jar"].each { |jar| require jar }

class Harbor
  module FTP
    def self.services
      @services ||= Container.new
    end
  end
end

class String
  def ensure_ends_with(partial)
    end_with?(partial) ? self : self + partial
  end
end

require "harbor/ftp/container"
require "harbor/ftp/user_manager"
require "harbor/ftp/readonly_user_manager_adapter"
require "harbor/ftp/server"