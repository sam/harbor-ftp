class Harbor
  module FTP
    # This class is intended for internal use only, adapting your own simple
    # User objects to the org.apache.ftpserver.ftplet.User interface.
    class UserAdapter
      
      include org.apache.ftpserver.ftplet.User
      include_package "org.apache.ftpserver.usermanager.impl"
      
      def initialize(user)
        @name = user.ftp_username
        @home_directory = user.ftp_home_directory
        
        @user_max_idle_time = if user.respond_to?(:ftp_max_idle_time)
          user.ftp_max_idle_time
        else
          0
        end
        @max_idle_time = @user_max_idle_time
        
        @authorities = []
        
        @authorities << WritePermission.new
        @authorities << ConcurrentLoginPermission.new(0, 0)
        @authorities << TransferRatePermission.new(0, 0)
      end
      
      def self.new_with_timeout(user, timeout)
        user = new(user)
        user.max_idle_time = timeout
        user
      end
      
      attr_accessor :name, :home_directory, :authorities
      
      def max_idle_time
        @max_idle_time
      end
      
      def max_idle_time=(value)
        if value.nil?
          @max_idle_time = 0
        elsif value.is_a?(Fixnum)
          if @user_max_idle_time != 0
            @max_idle_time = @user_max_idle_time
          else
            @max_idle_time = value
          end
        else
          raise ArgumentError.new("+max_idle_time=+ only accepts nil or Fixnum")
        end
      end
      
      def enabled?
        true
      end
      
      # We do not expose the password here since it's unnecessary and
      # may not be available depending on your wrapped user's password
      # implementation.
      def password
        nil
      end
      
      def authorize(request)
        if authority = @authorities.detect { |a| a.can_authorize(request) }
          authority.authorize(request)
        end
      end
      
    end # class UserAdapter
  end # module FTP
end # class Harbor