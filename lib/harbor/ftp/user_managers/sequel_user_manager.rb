require "sequel"

class Harbor
  module FTP
    module UserManagers
      class SequelUserManager
        include UserManager
      
        def initialize(user_model, key = :email)
          @user_model = user_model
          @key = key
        end
        
        def get_user_by_name(username)
          @user_model.first(@key => username)
        end
      
        def get_all_user_names
          @user_model.map(@key)
        end
      
        def exists?(username)
          @user_model.select(1).where(
            @user_model.filter(@key => username).exists
          ).single_value == 1
        end
      
      end # class SequelUserManager
    end # module UserManagers
  end # module FTP
end # class Harbor