class Harbor
  module FTP
    # This class is intended for internal use only, adapting your own simple
    # User objects to the org.apache.ftpserver.ftplet.User interface.
    class UserAdapter
      
      include org.apache.ftpserver.ftplet.User
      
      def initialize(user)
        @name = user.ftp_username
        @home_directory = user.ftp_home_directory
        @authorities = []
        @max_idle_time = user.respond_to?(:ftp_max_idle_time) ? user.ftp_max_idle_time : 0
      end
      
      attr_accessor :name, :home_directory, :authorities, :max_idle_time
      
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
        true
      end
      
    end # class UserAdapter
  end # module FTP
end # class Harbor