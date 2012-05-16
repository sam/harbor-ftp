require "harbor/ftp/user_managers/anonymous_user_manager"
require "thread"

class Harbor
  module FTP
    class Server
      
      include_package "org.apache.ftpserver"
      include_package "org.apache.ftpserver.listener"

      def initialize
        @started = false
        @port = 21
        @user_manager = ReadonlyUserManagerAdapter.new(UserManagers::AnonymousUserManager.new)
        @timeout = @user_manager.timeout = 300
        @server = nil
        @semaphore = Mutex.new
      end
      
      attr_reader :port, :timeout
      
      def port=(value)
        raise RunningConfigurationChangeError.new("port") if @started
        raise InvalidPortError.new unless value.is_a?(Fixnum)
        raise PortNotInRange.new unless (2..65535).include?(value)
        @semaphore.synchronize do
          @port = value
        end
      end
      
      def timeout=(value)
        raise InvalidTimeoutError.new unless value.is_a?(Fixnum)
        @semaphore.synchronize do
          @timeout = value
        end
      end
      
      def user_manager=(value)
        @semaphore.synchronize do
          @user_manager = ReadonlyUserManagerAdapter.new(value)
          @user_manager.timeout = @timeout
          @user_manager
        end
      end
      
      # This returns the wrapped UserManager implementation.
      def user_manager
        @user_manager.user_manager
      end
      
      def start
        @semaphore.synchronize do
          raise ServerAlreadyStartedError.new if @started
          @started = true

          # Setup your server:
          server_factory = FtpServerFactory.new
          listener_factory = ListenerFactory.new

          listener_factory.port = @port

          server_factory.user_manager = @user_manager if @user_manager
        
          server_factory.add_listener "default", listener_factory.create_listener

          @server = server_factory.create_server
        
          @server.start
        end
      end
      
      def stop
        @semaphore.synchronize do
          if @server && @started
            @server.stop
            true
          else
            raise ServerNotStartedError.new
          end
        end
      end
      
      class ServerAlreadyStartedError < StandardError
      end
      
      class ServerNotStartedError < StandardError
        def initialize
          super("The server isn't running, so can't stop won't stop.")
        end
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
      
      class InvalidTimeoutError < StandardError
        def initialize
          super("+timeout+ must be a Fixnum")
        end
      end
      
    end # class Server
  end # module FTP
end # class Harbor