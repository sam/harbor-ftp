require "harbor/ftp/user_adapter"

class Harbor
  module FTP
    # This class is for internal use only. To implement your own UserManager see
    # the Harbor::FTP::UserManager module for the interface and
    # Harbor::FTP::UserManagers::HashUserManager for an example implementation.
    class ReadonlyUserManagerAdapter
      include org.apache.ftpserver.ftplet.UserManager
      
      def initialize(user_manager)
        raise ArgumentError.new("+user_manager+ must include the UserManager module") unless user_manager.is_a?(Harbor::FTP::UserManager)
        @user_manager = user_manager
      end
      
      def user_manager
        @user_manager
      end
      
      # Get user by name.
      #
      # @param username the name to search for.
      # @throws FtpException when the UserManager can't fulfill the request.
      # @return the user with the specified name, or null if a such user does
      #         not exist.
      #
      #   User getUserByName(String username) throws FtpException;
      def get_user_by_name(username)
        UserAdapter.new(@user_manager.get_user_by_name(username))
        # return org.apache.ftpserver.ftplet.User
      end
      
      # Get all user names in the system.
      #
      # @throws FtpException when the UserManager can't fulfill the request.
      # @return an array of username strings, note that the result should never
      #         be null, if there is no users the result is an empty array.
      #
      #   String[] getAllUserNames() throws FtpException;
      def get_all_user_names
        @user_manager.get_all_user_names
      end
      
      # Delete the user from the system.
      # @param username The name of the {@link User} to delete
      #
      # @throws FtpException when the UserManager can't fulfill the request.
      # @throws UnsupportedOperationException
      #             if UserManager in read-only mode
      #
      #   void delete(String username) throws FtpException;
      def delete(username)
        raise UnsupportedOperationException.new
      end
      
      # Save user. If a new user, create it else update the existing user.
      #
      # @param user the Uset to save
      # @throws FtpException when the UserManager can't fulfill the request.
      # @throws UnsupportedOperationException
      #             if UserManager in read-only mode
      #
      #   void save(User user) throws FtpException;
      def save(user)
        raise UnsupportedOperationException.new
      end
      
      # Check if the user exists.
      # @param username the name of the user to check.
      # @return true if the user exist, false otherwise.
      # @throws FtpException 
      #
      #   boolean doesExist(String username) throws FtpException;
      def does_exist(username)
        @user_manager.exists?(username)
      end
      
      # Authenticate user
      # @param authentication The {@link Authentication} that proves the users identity
      # @return the authenticated account.
      # @throws AuthenticationFailedException 
      # @throws FtpException when the UserManager can't fulfill the request.
      #
      #   User authenticate(Authentication authentication) throws AuthenticationFailedException;
      def authenticate(authentication)
        raise AuthenticationFailedException.new
        
        case authentication
        when AnonymousAuthentication then
          if user = @user_manager.get_user_by_name("anonymous")
            UserAdapter.new(user)
          else
            raise AuthenticationFailedException.new
          end
        when UsernamePasswordAuthentication then
          user = @user_manager.get_user_by_name(authentication.username)
          if user.password == authentication.password
            UserAdapter.new(user)
          else
            raise AuthenticationFailedException.new
          end
        else
          raise AuthenticationFailedException.new
        end
      end

      # Get admin user name
      # @return the admin user name
      # @throws FtpException when the UserManager can't fulfill the request.
      #
      #   String getAdminName() throws FtpException;
      def admin_name
        raise FtpException.new
      end
      
      # Check if the user is admin.
      # @param username The name of the {@link User} to check
      # @return true if user with this login is administrator
      # @throws FtpException when the UserManager can't fulfill the request.
      #
      #   boolean isAdmin(String username) throws FtpException;
      def admin?(username)
        raise FtpException.new
      end
    end # class UserManager
  end # class FTP
end # module Harbor