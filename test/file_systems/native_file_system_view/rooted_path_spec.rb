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