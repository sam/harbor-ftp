require "sequel"
require_relative "sequel_user_manager/user"

class Harbor
  module FTP
    module UserManagers
      class SequelUserManager
        include UserManager
      
        def initialize(user_model = SequelUserManager::User)
          @user_model = user_model
        end
        
        def get_user_by_name(username)
          @user_model.first(:email => username)
        end
      
        def get_all_user_names
          @user_model.map(:email)
        end
      
        def exists?(username)
          @user_model.select(1).where(
            @user_model.filter(:email => username).exists
          ).single_value == 1
        end
      
      end # class SequelUserManager
    end # module UserManagers
  end # module FTP
end # class Harbor