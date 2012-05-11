require "harbor/ftp/user_managers/sequel_user_manager"

class Harbor
  module FTP
    module UserManagers
      class SequelUserManager
        class User < Sequel::Model
          extend Spawn
      
          spawner do |user|
            user.name = Faker::Name.name
            user.email = Faker::Internet.email
            user.password = "secret"
          end
        end # class User
      end # SequelUserManager
    end # UserManagers
  end # module FTP
end # class Harbor   