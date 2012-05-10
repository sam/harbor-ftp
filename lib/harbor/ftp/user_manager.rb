require "sequel"
require "harbor/ftp/user"

class Harbor
  module FTP
    class UserManager
      include org.apache.ftpserver.ftplet.UserManager
      
      # Get user by name.
      #
      # @param username the name to search for.
      # @throws FtpException when the UserManager can't fulfill the request.
      # @return the user with the specified name, or null if a such user does
      #         not exist.
      #
      #   User getUserByName(String username) throws FtpException;
      def get_user_by_name(username)
        DB[:users].find(:email => username)
        raise NotImplementedError.new
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
        DB[:users].all(:select => [ :email ])
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
      def exists?(username)
        DB.select(1).where(
          DB[:users].filter(:email => username).exists
        ).single_value == 1
      end
      
      # Authenticate user
      # @param authentication The {@link Authentication} that proves the users identity
      # @return the authenticated account.
      # @throws AuthenticationFailedException 
      # @throws FtpException when the UserManager can't fulfill the request.
      #
      #   User authenticate(Authentication authentication) throws AuthenticationFailedException;
      def authenticate(authentication)
        raise NotImplementedError.new
        # return org.apache.ftpserver.ftplet.User
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