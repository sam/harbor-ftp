#!/usr/bin/env jruby

require_relative "../../helper"

describe Harbor::FTP::FileSystems::NativeFileSystemView::RootedPath do

  before do
    @root = (Pathname(__FILE__).dirname.parent.parent.parent + "tmp" + "native_file_system_view")
    @root.mkdir
    @root = @root.realpath
  end
  
  after do
    @root.rmdir
  end
  
  describe "request" do
    it "must return root if you try to traverse above root with an absolute path" do
      path = Harbor::FTP::FileSystems::NativeFileSystemView::RootedPath.new(@root)
      path.request("/../").must_equal @root
    end
  end
  
end

# class Harbor
#   module FTP
#     module FileSystems
#       class NativeFileSystemView
#         class RootedPath
#           include Loggable
#           
#           def initialize(root)
#             @root = @current = Pathname(root).realpath
#           end
#   
#           def root
#             @root
#           end
#           
#           def to_s
#             @root.to_s
#           end
#           
#           def cwd
#             @current
#           end
#           
#           def chdir(path)
#             path = request(path)
#             return false unless path.directory?
# 
#             @current = path
#             true
#           end
#   
#           def request(path)
#             # @root and @current are Pathname objects.
#             # This conditional determines if you've asked for
#             # an absolute-path (from your root), or a relative-path
#             # (within your current working directory).
#             path = if path.start_with? "/"
#               @root + path[1..-1]
#             else
#               (@current + path)
#             end.realpath
#             
#             ensure_rooted path
#           end
#   
#           private
#           # Ensure that we "chroot" all requests to the @root_dir.
#           # ie: If you pass:  "#{@root}/../" to this method, we need to ensure
#           # that we don't allow you to actually get that path since
#           #   (@root + path).realpath
#           # ..would calculate out your traversal and return you a path
#           # outside of what you should be allowed to see.
#           def ensure_rooted(pathname)
#             if pathname.to_s.start_with? @root.to_s
#               pathname
#             else
#               @root
#             end
#           end
#         end # class RootedPath
#       end # class NativeFileSystemView
#     end # module FileSystems
#   end # module FTP
# end # class Harbor