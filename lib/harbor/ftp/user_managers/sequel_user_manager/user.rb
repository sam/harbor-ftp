class Harbor
  module FTP
    module UserManagers
      class SequelUserManager
        class User < Sequel::Model
          unrestrict_primary_key
      
          def ftp_username
            email
          end
      
          # User should have:
          #   ftp_username : String
          #   ftp_home_directory : String
          #   password : Must return an object that responds to #== for
          #                comparison with a plain-text password.
          #                For example, this could be a plain-text password
          #                String, or a BCrypt::Password object.
          #
          # Optional:
          #   ftp_max_idle_time : Fixnum (in seconds)
      
        end # class User
      end # SequelUserManager
    end # UserManagers
  end # module FTP
end # class Harbor