class Harbor
  module FTP
    module MemoryUserManager
      
      include_package "org.apache.ftpserver.ftplet"
      include_package "org.apache.ftpserver.usermanager"
      
      DEFAULT_HOME = Pathname(__FILE__).dirname.parent.parent.parent + "tmp"
      
      def initialize
        user_manager_factory = PropertiesUserManagerFactory.new
        user_manager_factory.password_encryptor = ClearTextPasswordEncryptor.new

        @user_manager = user_manager_factory.create_user_manager
      end
      
      def add_user(username, password, home_directory = DEFAULT_HOME)
        user_factory = UserFactory.new
        user_factory.name = username
        user_factory.password = password
        user_factory.home_directory = home_directory
        user = user_factory.create_user

        @user_manager.save user
      end
      
      def instance
        @user_manager
      end
    end # class SampleUserManager
  end # module FTP
end # class Harbor