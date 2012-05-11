class Harbor
  module FTP
    module UserManagers
      # This is a stub User class to use as a starting point for your own UserManagers.
      # It's used in the simpler implementations like HashUserManager.
      class User
        
        attr_accessor :ftp_username,
          :password,
          :ftp_home_directory,
          :ftp_max_idle_time
    
        def initialize(ftp_username = nil, password = nil, ftp_home_directory = nil, ftp_max_idle_time = 0)
          @ftp_username = ftp_username
          @password = password
          @ftp_home_directory = ftp_home_directory
          @ftp_max_idle_time = ftp_max_idle_time
        end
    
      end # class User
    end # UserManagers
  end # module FTP
end # class Harbor