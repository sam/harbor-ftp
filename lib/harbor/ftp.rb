lib = (Pathname(__FILE__).dirname.parent).to_s
$:.unshift lib unless $:.include?(lib)

require "java"

Dir[Pathname(__FILE__).dirname.parent.parent + "jars" + "*.jar"].each { |jar| require jar }

class Harbor
  module FTP
    def self.services
      @services ||= Container.new
    end
    
    def self.underscore(string)
      string.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
    end
  end
end

require "harbor/ftp/container"
require "harbor/ftp/controller"
require "harbor/ftp/command"
require "harbor/ftp/user_manager"
require "harbor/ftp/readonly_user_manager_adapter"
require "harbor/ftp/server"