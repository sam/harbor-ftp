require_relative "hash_user_manager"

class Harbor
  module FTP
    module UserManagers
      # This UserManager simply enables Anonymous logins only.
      class AnonymousUserManager < HashUserManager
        include UserManager
        
        def initialize
          super
          add_user("anonymous", nil, DEFAULT_HOME)
        end
      
      end # class HashUserManager
    end # module UserManagers
  end # module FTP
end # class Harbor