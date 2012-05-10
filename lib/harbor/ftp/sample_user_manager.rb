class Harbor
  module FTP
    module SampleUserManager
      
      include_package "org.apache.ftpserver.ftplet"
      include_package "org.apache.ftpserver.usermanager"
      
      def self.setup(username, password)
        # Setup your login:
        user_manager_factory = PropertiesUserManagerFactory.new
        user_manager_factory.password_encryptor = ClearTextPasswordEncryptor.new

        user_manager = user_manager_factory.create_user_manager

        user_factory = UserFactory.new
        user_factory.name = username
        user_factory.password = password
        user_factory.home_directory = File.dirname(__FILE__)
        user = user_factory.create_user

        user_manager.save user
        user_manager
      end
    end # class SampleUserManager
  end # module FTP
end # class Harbor