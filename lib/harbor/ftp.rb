lib = (Pathname(__FILE__).dirname.parent).to_s
$:.unshift lib unless $:.include?(lib)

require "java"

Dir[Pathname(__FILE__).dirname.parent.parent + "jars" + "*.jar"].each { |jar| require jar }

# require "harbor/ftp/command"
require "harbor/ftp/user_manager"
require "harbor/ftp/readonly_user_manager_adapter"
require "harbor/ftp/server"