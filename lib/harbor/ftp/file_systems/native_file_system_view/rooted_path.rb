class Harbor
  module FTP
    module FileSystems
      class NativeFileSystemView
        class RootedPath
          include Loggable
          
          def initialize(root)
            @home = @current = Pathname(root).realpath
          end
          
          def to_s
            @current.to_s
          end
          
          def home
            @home
          end
          
          def cwd
            @current
          end
          
          def chdir(path)
            path = request(path)
            return false unless path.directory? && path != @home

            @current = path
            true
          end
  
          def request(path)
            # @root and @current are Pathname objects.
            # This conditional determines if you've asked for
            # an absolute-path (from your root), or a relative-path
            # (within your current working directory).
            path = if path.start_with? "/"
              @home + path[1..-1]
            else
              (@current + path)
            end.realpath
            
            ensure_rooted path
          end
  
          private
          # Ensure that we "chroot" all requests to the @root_dir.
          # ie: If you pass:  "#{@root}/../" to this method, we need to ensure
          # that we don't allow you to actually get that path since
          #   (@root + path).realpath
          # ..would calculate out your traversal and return you a path
          # outside of what you should be allowed to see.
          def ensure_rooted(pathname)
            if pathname.to_s.start_with? @home.to_s
              pathname
            else
              LOG.warn { "attempt to traverse above home: #{pathname}" }
              @home
            end
          end
        end # class RootedPath
      end # class NativeFileSystemView
    end # module FileSystems
  end # module FTP
end # class Harbor