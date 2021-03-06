require_relative "native_ftp_file/file_output_stream"
require_relative "native_ftp_file/file_input_stream"

class Harbor
  module FTP
    module FileSystems
      class NativeFtpFile
        include Loggable
        
        include_package "org.apache.ftpserver.ftplet"
        include_package "org.apache.ftpserver.usermanager.impl"
        
        include FtpFile
        
        def initialize(path, file, user)
          ArgumentError.new("path can not be nil") unless path
          ArgumentError.new("file can not be nil") unless file
          ArgumentError.new("path can not be empty") if path.empty?
          ArgumentError.new("path must be absolute") unless path.start_with? "/"
          
          @path = Pathname(path) # Originally: fileName
          @file = file
          @user = user
        end

        def get_absolute_path
          @path.to_s
        end
        
        def basename
          # If it's a directory, should we return ./ instead of the name?
          @path.basename.to_s
        end
        alias_method :getName, :basename
        
        def hidden?
          @file.hidden?
        end
        
        def directory?
          @file.directory?
        end
        alias_method :isDirectory, :directory?

        def file?
          @file.file?
        end
        alias_method :isFile, :file?
        
        def exists?
          @file.exists?
        end
        alias_method :doesExist, :exists?
        
        def readable?
          @file.can_read?
        end
        
        def writable?
          LOG.debug { "Checking authorization for #{get_absolute_path}" }
          
          if !@user.authorize(WriteRequest.new(get_absolute_path))
            LOG.debug { "Not authorized" }
            return false
          end

          LOG.debug { "Checking if file exists" }
          if exists?
            result = @file.can_write?
            LOG.debug { "Checking can write: #{result}" }
            return result
          end

          LOG.debug { "Authorized" }
          return true
        end
        
        def get_owner_name
          "user"
        end
        
        def get_group_name
          "group"
        end
        
        def get_link_count
          @file.directory? ? 3 : 1
        end
        
        def size
          @file.length
        end
        alias_method :getSize, :size
        
        def file
          @file
        end
        alias_method :getPhysicalFile, :file
        
        def last_modified
          @file.last_modified
        end
        alias_method :getLastModified, :last_modified
        
        def last_modified=(time)
          @file.set_last_modified(time)
        end
        alias_method :setLastModified, :last_modified=
        
        def delete
          return @file.delete if removable?
          false
        end
        
        def mkdir
          return @file.mkdir if writable?
          false
        end
        
        def hash
          @file.canonical_path.hash
        rescue java.io.IOException
          0
        end
        alias_method :getHashCode, :hash
        
        def ==(other)
          if other.is_a?(NativeFtpFile)
            return @file.canonical_path == other.file.canonical_path
          end
          false
        rescue java.io.IOException => e
          raise java.lang.RuntimeException.new("Failed to get the canonical path", e)
        end
        alias_method :equals, :==
        
        def move(destination)
          if readable? && destination.writable?
            return false if destination.exists?
            @file.rename_to(destination.file)
          else
            false
          end
        end
        
        def removable?
          return false if @path.to_s == "/"
          return false unless @user.authorize(WriteRequest.new(@path.to_s))
          return NativeFtpFile.new(@path.parent.to_s, @file, @user).writable?
        end
        
        def list_files
          return nil unless @file.directory?
          
          files = @file.list_files
          return nil unless files
          
          files.sort.map do |file|
            NativeFtpFile.new((@path + file.name).to_s, file, @user)
          end
        end
      
        def create_output_stream(offset)
          raise java.io.IOException.new("No write permission : #{@file.name}") unless writable?
          FileOutputStream.new(@file, offset)
        end

        def create_input_stream(offset)
          raise java.io.IOException.new("No read permission : #{@file.name}") unless readable?          
          FileInputStream.new(@file, offset)
        end
        
      end # class NativeFtpFile
    end # module FileSystems
  end # module FTP
end # class Harbor