class Harbor
  module FTP
    class User < Sequel::Model
      extend Spawn
      
      spawner do |user|
        user.name = Faker::Name.name
        user.email = Faker::Internet.email
        user.password = Faker::Password.password
      end
    end # class User
  end # module FTP
end # class Harbor   