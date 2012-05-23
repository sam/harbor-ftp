require_relative "native_ftp_file"

class Harbor
  module FTP
    module FileSystems
      class NativeFileSystemView
          
        include_package "org.apache.ftpserver.ftplet"
        
        include FileSystemView
        
        def initialize(user, case_insensitive = false)
          raise ArgumentError.new("user can not be nil") unless user
          raise ArgumentError.new("user home directory can not be nil") unless user.home_directory

          @user = user
          @root_dir = @current_dir = Pathname(@user.home_directory.ensure_ends_with("/"))
          
          LOG.debug { "View created for user \"#{@user.name}\" with root \"#{@root_dir}\"" }
        end
        
        def case_insensitive?
          false
        end
        
        def random_accessible?
          true
        end
        
        def home_directory
          NativeFtpFile.new "/", java.io.File.new(@root_dir.realpath.to_s), @user
        end
        
        def working_directory
          NativeFtpFile.new "/", java.io.File.new(@current_dir.realpath.to_s), @user
        end
        
        def get_file(path)
          LOG.debug { "get_file(\"#{path}\") :: @root_dir[#{@root_dir}]" }
          path = get_physical_name(path)
          LOG.debug { "PATH: #{path}" }
          
          file = java.io.File.new(path)
          
          NativeFtpFile.new path, file, @user
        end
        
        def change_working_directory(dir)
          LOG.debug { "change_working_directory(\"#{dir}\")" }
          dir = get_physical_name(dir)   
          
          if Pathname(dir).directory?
            @current_dir = Pathname(dir)
          else
            LOG.error { "dir does not exist! #{dir}" }
            return false
          end
          
          return true
        end
        
        def dispose
          nil
        end
        
        private
        
        LOG = RJack::SLF4J[self]
        
        def get_physical_name(path)
          path = if path.start_with? "/"
            (@root_dir + path).realpath.to_s
          else
            LOG.debug { "get_physical_name: relative_path: @root_dir: #{@root_dir} @current_dir: #{@current_dir} @path: #{path}" }
            (@current_dir + path).realpath.to_s
          end
          
          if path.start_with? @root_dir.realpath.to_s
            path
          else
            @root_dir.realpath.to_s
          end
        end
        
      end # class NativeFileSystemView
    end # module FileSystems
  end # module FTP
end # class Harbor