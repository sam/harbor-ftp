require_relative "native_file_system_view"

class Harbor
  module FTP
    module FileSystems
      class NativeFileSystemFactory
        include Loggable
        
        include_package "org.apache.ftpserver.ftplet"
        include FileSystemFactory
        
        def initialize
          @create_home = false
        end
        
        def create_home=(value)
          unless value == true || value == false
            raise ArgumentError.new("create_home value must be +true+ or +false+") 
          end
          @create_home = value
        end
        
        def create_home?
          @create_home
        end
        
        def case_insensitive?
          false
        end
        
        declare_private_constant :SEMAPHORE, Mutex.new
        def create_file_system_view(user)
          SEMAPHORE.synchronize do
            if create_home?
              home_directory = Pathname(user.home_directory)
              if home_directory.exist?
                unless home_directory.directory?
                  LOG.warn { "Not a directory :: #{home_directory}" }
                  raise FtpException.new("Not a directory :: #{home_directory}")
                end
              else
                unless home_directory.mkpath
                  LOG.warn { "Cannot create user home :: #{home_directory}" }
                  FtpException.new("Cannot create user home :: #{home_directory}")
                end
              end
            end
            
            FileSystems::NativeFileSystemView.new(user, case_insensitive?)
          end
        end
        
      end # class NativeFileSystemFactory
    end # module FileSystems
  end # module FTP
end # class Harbor