require_relative "native_file_system_view/rooted_path"
require_relative "native_ftp_file"

class Harbor
  module FTP
    module FileSystems
      class NativeFileSystemView
        include Loggable
        
        include_package "org.apache.ftpserver.ftplet"
        
        include FileSystemView
        
        def initialize(user, case_insensitive = false)
          raise ArgumentError.new("user can not be nil") unless user
          raise ArgumentError.new("user home directory can not be nil") unless user.home_directory

          @user = user
          @root = RootedPath.new @user.home_directory.ensure_ends_with("/")
          
          LOG.debug { "View created for user \"#{@user.name}\" with root \"#{@root}\"" }
        end
        
        def case_insensitive?
          false
        end
        
        def random_accessible?
          true
        end
        
        def home_directory
          NativeFtpFile.new "/", java.io.File.new(@root.to_s), @user
        end
        
        def working_directory
          NativeFtpFile.new "/", java.io.File.new(@root.cwd.to_s), @user
        end
        
        def get_file(path)
          LOG.debug { "get_file(\"#{path}\")" }

          path = @root.request(path)
          file = java.io.File.new(path.to_s)
          
          NativeFtpFile.new "/#{path.relative_path_from(@root.home)}", file, @user
        end
        
        def change_working_directory(dir)
          LOG.debug { "change_working_directory(\"#{dir}\")" }

          result = @root.chdir(dir)
          LOG.warn { "dir does not exist! #{dir}" } unless result
          result
        end
        
        # This method isn't used in the original either,
        # but the interface requires us to impelement it.
        def dispose
          nil
        end
                
      end # class NativeFileSystemView
    end # module FileSystems
  end # module FTP
end # class Harbor