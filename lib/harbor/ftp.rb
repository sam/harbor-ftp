lib = (Pathname(__FILE__).dirname.parent).to_s
$:.unshift lib unless $:.include?(lib)

require "java"

require "rjack-logback"
RJack::Logback.config_console( :level => :error )

Dir[Pathname(__FILE__).dirname.parent.parent + "jars" + "*.jar"].each { |jar| require jar }

require "harbor/ftp/loggable"

class Harbor
  module FTP
    def self.services
      @services ||= Container.new
    end
    
    # Simple helper method to silence warnings (mostly in tests).
    # Declared here to guarantee we avoid conflicting with other libraries.
    def self.suppress_warnings
      original_verbosity, $VERBOSE = $VERBOSE, nil
      result = yield
      $VERBOSE = original_verbosity
      return result
    end
  end
end

class Module
  def declare_private_constant(name, value)
    const_set name, value
    private_constant name
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
require "harbor/ftp/route"