# package org.apache.ftpserver.filesystem.nativefs;

# import java.io.File;

# import org.apache.ftpserver.filesystem.nativefs.impl.NativeFileSystemView;
# import org.apache.ftpserver.ftplet.FileSystemFactory;
# import org.apache.ftpserver.ftplet.FileSystemView;
# import org.apache.ftpserver.ftplet.FtpException;
# import org.apache.ftpserver.ftplet.User;

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
              home_directory = user.home_directory
              if FileUtils::dir?(home_directory)
                LOG.warn { "Not a directory :: #{home_directory}" }
                raise FtpException.new("Not a directory :: #{home_directory}")
              end
              
              if !File::exists?(home_directory) && !FileUtils::mkdir_p(home_directory)
                LOG.warn { "Cannot create user home :: #{home_directory}" }
                FtpException.new("Cannot create user home :: #{home_directory}")
              end
            end
            
            NativeFileSystemView.new(user, case_insensitive?)
          end
        end
        
        private
        SEMAPHORE = Mutex.new
        LOG = RJack::SLF4J.logger
        
      end # class NativeFileSystemFactory
    end # module FileSystems
  end # module FTP
end # class Harbor