class Harbor
  module FTP
    module UserManagers
      class HashUserManager
        include UserManager

        DEFAULT_HOME = "/tmp"
        
        def initialize
          @users = {}
        end
      
        def add_user(username, password, home_directory = DEFAULT_HOME)
          @users[username] = User.new username, password, home_directory
        end
      
        def get_user_by_name(username)
          @users[username]
        end
      
        def get_all_user_names
          @users.keys
        end
      
        def exists?(username)
          @users.key?(username)
        end
      
      end # class HashUserManager
    end # module UserManagers
  end # module FTP
end # class Harbor