require "sequel"
require "harbor/ftp/user"

class Harbor
  module FTP
    module UserManagers
      class SequelUserManager
        include UserManager
      
        def get_user_by_name(username)
          DB[:users].find(:email => username)
        end
      
        def get_all_user_names
          DB[:users].map(:email)
        end
      
        def exists?(username)
          DB.select(1).where(
            DB[:users].filter(:email => username).exists
          ).single_value == 1
        end
      
      end # class SequelUserManager
    end # module UserManagers
  end # module FTP
end # class Harbor