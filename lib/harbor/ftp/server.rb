class Harbor
  module FTP
    class Server
      
      include_package "org.apache.ftpserver"
      include_package "org.apache.ftpserver.ftplet"
      include_package "org.apache.ftpserver.usermanager"
      include_package "org.apache.ftpserver.listener"

      def initialize(background = false)
        @started = false
        @port = 21
      end
      
      attr_reader :port
      
      def port=(value)
        raise RunningConfigurationChangeError.new("port") if @started
        raise InvalidPortError.new unless value.is_a?(Fixnum)
        raise PortNotInRange.new unless (2..65535).include?(value)
        @port = value
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

        listener_factory.port = @port

        server_factory.user_manager = user_manager
        server_factory.add_listener "default", listener_factory.create_listener

        server = server_factory.create_server
        
        server.start
      end
      
      class ServerAlreadyStartedError < StandardError
      end
      
      class RunningConfigurationChangeError < StandardError
        def initialize(option)
          super("+#{option}+ cannot be changed after the server is started")
        end
      end
      
      class PortNotInRange < StandardError
        def initialize
          super("+port+ must be a number between 2 and 65535")
        end
      end
      
      class InvalidPortError < StandardError
        def initialize
          super("+port+ must be a Fixnum")
        end
      end
    end # class Server
  end # module FTP
end # class Harbor