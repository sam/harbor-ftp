require_relative "native_file_system_view"

class Harbor
  module FTP
    module FileSystems
      class NativeFileSystemFactory
        
        include_package "org.apache.ftpserver.ftplet"
        include_package "org.apache.ftpserver.filesystem.nativefs.impl"
        
        include FileSystemFactory
        
        def initialize
          @create_home = false
        end
        
        def create_home=(value)
          @create_home = value
        end
        
        def create_home?
          @create_home
        end
        
        def case_insensitive?
          false
        end
        
        def create_file_system_view(user)
          SEMAPHORE.synchronize do
            if create_home?
              # TODO: None of this branch is stressed in the tests.
              home_directory = user.home_directory
              if File::directory?(home_directory)
                LOG.warn { "Not a directory :: #{home_directory}" }
                raise FtpException.new("Not a directory :: #{home_directory}")
              end
              
              if !File::exists?(home_directory) && !FileUtils::mkdir_p(home_directory)
                LOG.warn { "Cannot create user home :: #{home_directory}" }
                FtpException.new("Cannot create user home :: #{home_directory}")
              end
            end
            
            FileSystems::NativeFileSystemView.new(user, case_insensitive?)
          end
        end
        
        private
        SEMAPHORE = Mutex.new
        LOG = RJack::SLF4J.logger
        
      end # class NativeFileSystemFactory
    end # module FileSystems
  end # module FTP
end # class Harbor