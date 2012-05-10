lib = (Pathname(__FILE__).dirname.parent).to_s
$:.unshift lib unless $:.include?(lib)

require "java"

Dir[Pathname(__FILE__).dirname.parent.parent + "jars" + "*.jar"].each { |jar| require jar }

require "harbor/ftp/server"

class Harbor
  module FTP
    def self.user_database(connection_string)
      require "sequel"
      Sequel.connect(connection_string)
      require "harbor/ftp/user_manager"
    end
  end
end