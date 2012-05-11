require "harbor/ftp/user_managers/anonymous_user_manager"

class Harbor
  module FTP
    class Server
      
      include_package "org.apache.ftpserver"
      include_package "org.apache.ftpserver.listener"

      def initialize
        @started = false
        @port = 21
        @user_manager = ReadonlyUserManagerAdapter.new(UserManagers::AnonymousUserManager.new)
      end
      
      attr_reader :port, :user_manager
      
      def port=(value)
        raise RunningConfigurationChangeError.new("port") if @started
        raise InvalidPortError.new unless value.is_a?(Fixnum)
        raise PortNotInRange.new unless (2..65535).include?(value)
        @port = value
      end
      
      def user_manager=(value)
        @user_manager = ReadonlyUserManagerAdapter.new(value)
      end
      
      def start
        raise ServerAlreadyStartedError.new if @started
        @started = true

        # Setup your server:
        server_factory = FtpServerFactory.new
        listener_factory = ListenerFactory.new

        listener_factory.port = @port

        server_factory.user_manager = @user_manager if @user_manager
        
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