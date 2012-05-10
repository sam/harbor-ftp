require "pathname"
require "java"

Dir[Pathname("apache-ftpserver-1.0.6/common/lib/*.jar")].each { |jar| require jar }

class Harbor
  module FTP
    class Server
      
      include_package "org.apache.ftpserver"
      include_package "org.apache.ftpserver.ftplet"
      include_package "org.apache.ftpserver.usermanager"
      include_package "org.apache.ftpserver.listener"

      def initialize(background = false)
        @background = background
        @started = false
      end
      
      def start
        raise ServerAlreadyStartedError.new if @started
        @started = true
        
        # Setup your login:
        user_manager_factory = PropertiesUserManagerFactory.new
        user_manager_factory.password_encryptor = ClearTextPasswordEncryptor.new

        user_manager = user_manager_factory.create_user_manager

        user_factory = UserFactory.new
        user_factory.name = "me"
        user_factory.password = "secret"
        user_factory.home_directory = File.dirname(__FILE__)
        user = user_factory.create_user

        user_manager.save user

        # Setup your server:
        server_factory = FtpServerFactory.new
        listener_factory = ListenerFactory.new

        listener_factory.port = 2221

        server_factory.user_manager = user_manager
        server_factory.add_listener "default", listener_factory.create_listener

        server = server_factory.create_server

        # Start the server
        server_thread = Thread.new do
          server.start
        end
        
        server_thread.join unless @background
        
        server
      end
      
      class ServerAlreadyStartedError < StandardError
      end
    end # class Server
  end # module FTP
end # class Harbor