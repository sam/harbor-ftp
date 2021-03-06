require_relative "hash_user_manager"

class Harbor
  module FTP
    module UserManagers
      # This UserManager simply enables Anonymous logins only.
      class AnonymousUserManager < HashUserManager
        include UserManager
        
        def initialize
          super
          add_user("anonymous", "", DEFAULT_HOME)
        end
        
        def home_directory=(home_directory)
          add_user("anonymous", "", home_directory)
        end
      
      end # class HashUserManager
    end # module UserManagers
  end # module FTP
end # class Harbor