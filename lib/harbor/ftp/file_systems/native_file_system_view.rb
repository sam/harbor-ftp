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
          LOG.debug { "get_file(\"#{path}\")" }
          path = get_physical_name(path)
          
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
        
        # This method isn't used in the original either,
        # but the interface requires us to impelement it.
        def dispose
          nil
        end
        
        def get_physical_name(path)
          # @root_dir and @current_dir are Pathname objects.
          # This conditional determines if you've asked for
          # an absolute-path (from your root), or a relative-path
          # (within your current working directory).
          path = if path.start_with? "/"
            (@root_dir + path).realpath.to_s
          else
            (@current_dir + path).realpath.to_s
          end
          
          # Ensure that we "chroot" all requests to the @root_dir.
          # ie: If you pass: "/../" to this method, we need to ensure
          # that we don't allow you to actually get that path since
          #   (@root_dir + path).realpath
          # ..would calculate out your traversal and return you a path
          # outside of what you should be allowed to see.
          if path.start_with? @root_dir.realpath.to_s
            path
          else
            # If you've tried to do something evil, we'll just kick
            # you back to your home_directory.
            @root_dir.realpath.to_s
          end
        end
        
        private

        LOG = RJack::SLF4J[self]
        
      end # class NativeFileSystemView
    end # module FileSystems
  end # module FTP
end # class Harbor