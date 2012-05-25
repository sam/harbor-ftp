#!/usr/bin/env jruby

require_relative "../helper"

describe Harbor::FTP::FileSystems::NativeFtpFile do
  
end

# class Harbor
#   module FTP
#     module FileSystems
#       class NativeFtpFile
#         include Loggable
#         
#         include_package "org.apache.ftpserver.ftplet"
#         include_package "org.apache.ftpserver.usermanager.impl"
#         
#         include FtpFile
#         
#         def initialize(path, file, user)
#           ArgumentError.new("path can not be nil") unless path
#           ArgumentError.new("file can not be nil") unless file
#           ArgumentError.new("path can not be empty") if path.empty?
#           ArgumentError.new("path must be absolute") unless path.start_with? "/"
#           
#           @path = path # Originally: fileName
#           @file = file
#           @user = user
#         end
# 
#         def get_absolute_path
#           Pathname(@path).realpath.to_s
#         end
#         
#         def get_name
#           # If it's a directory, should we return ./ instead of the name?
#           Pathname(@path).basename.to_s
#         end
#         
#         def hidden?
#           @file.hidden?
#         end
#         
#         def directory?
#           @file.directory?
#         end
#         alias_method :isDirectory, :directory?
# 
#         def file?
#           @file.file?
#         end
#         alias_method :isFile, :file?
#         
#         def exists?
#           @file.exists?
#         end
#         alias_method :doesExist, :exists?
#         
#         def readable?
#           @file.can_read?
#         end
#         
#         def writable?
#           LOG.debug { "Checking authorization for #{get_absolute_path}" }
#           
#           if !@user.authorize(WriteRequest.new(get_absolute_path))
#             LOG.debug { "Not authorized" }
#             return false
#           end
# 
#           LOG.debug { "Checking if file exists" }
#           if exists?
#             result = @file.can_write?
#             LOG.debug { "Checking can write: #{result}" }
#             return result
#           end
# 
#           LOG.debug { "Authorized" }
#           return true
#         end
#         
#         def get_owner_name
#           "user"
#         end
#         
#         def get_group_name
#           "group"
#         end
#         
#         def get_link_count
#           @file.directory? ? 3 : 1
#         end
#         
#         def get_last_modified
#           @file.last_modified
#         end
#         
#         def get_size
#           @file.length
#         end
#         
#         def get_physical_file
#           @file
#         end
#         
#         def set_last_modified(time)
#           @file.set_last_modified(time)
#         end
#         
#         def delete
#           return @file.delete if removable?
#           false
#         end
#         
#         def mkdir
#           return @file.mkdir if writable?
#           false
#         end
#         
#         def hash_code
#           @file.get_canonical_path.hash_code
#         rescue java.io.IOException
#           0
#         end
#         
#         def equals(other)
#           if other.is_a?(NativeFtpFile)
#             return @file.get_canonical_path == other.file.get_canonical_path
#           end
#           false
#         rescue java.io.IOException => e
#           raise java.lang.RuntimeException.new("Failed to get the canonical path", e)
#         end
#         
#         def move(destination)
#           if readable? && destination.writable?
#             return false if destination.exists?
#             @file.rename_to(destination.file)
#           end
#           false
#         end
#         
#         def removable?
#           return false if @path == "/"
#           return false unless @user.authorize(WriteRequest.new(get_absolute_path))
#           return NativeFtpFile.new(Pathname(@path).parent.to_s, file, @user).writable?
#         end
#         
#         def list_files
#           return nil unless @file.directory?
#           
#           files = @file.list_files
#           return nil unless files
#           
#           path = Pathname(get_absolute_path)
#           files.sort.map do |file|
#             NativeFtpFile.new((path + file.name).to_s, file, @user)
#           end
#         end
#       
#         def create_output_stream(offset)
#           raise java.io.IOException.new("No write permission : #{@file.name}") unless writable?
#           FileOutputStream.new(@file, offset)
#         end
# 
#         def create_input_stream(offset)
#           raise java.io.IOException.new("No read permission : #{@file.name}") unless readable?          
#           FileInputStream.new(@file, offset)
#         end
# 
#       end # class NativeFtpFile
#     end # module FileSystems
#   end # module FTP
# end # class Harbor