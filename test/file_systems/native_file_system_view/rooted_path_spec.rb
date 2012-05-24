#!/usr/bin/env jruby

require_relative "../../helper"

describe Harbor::FTP::FileSystems::NativeFileSystemView::RootedPath do

  before do
    @root = (Pathname(__FILE__).dirname.parent.parent.parent + "tmp" + "native_file_system_view" + "rooted_path")
    @root.mkpath
    @root = @root.realpath
    @rooted_path = Harbor::FTP::FileSystems::NativeFileSystemView::RootedPath.new(@root)
  end
  
  after do
    @root.rmtree
  end
  
  describe "request" do
    it "must return root if you try to traverse above root with an absolute path" do
      @rooted_path.request("/../").must_equal @root
    end
    
    it "must accept a relative path" do
      path = @root + "a" + "b"
      path.mkpath
      
      @rooted_path.request("a").must_equal path.parent.realpath
      @rooted_path.request("a/b").must_equal path.realpath
    end
    
    it "must accept an absolute path" do
      path = @root + "foo" + "bar"
      path.mkpath
      
      @rooted_path.request("/foo").must_equal path.parent.realpath
      @rooted_path.request("/foo/bar").must_equal path.realpath
    end
  end
  
  describe "to_s" do
    it "must return the String value of the current working directory" do
      @rooted_path.to_s.must_equal @root.to_s
    end
  end
  
  describe "home" do
    it "must return the root Pathname" do
      @rooted_path.home.must_equal @root
    end
  end
  
  describe "cwd" do
    it "must default to the root Pathname" do
      @rooted_path.cwd.must_equal @root
    end
  end
  
  describe "chdir" do
    it "must not allow you to chdir to a path above the root" do
      @rooted_path.chdir("/../").must_equal false
      @rooted_path.cwd.must_equal @root
    end
    
    it "must allow you to use a relative path" do
      relative_path = @root + "relative_path" + "sub_path"
      relative_path.mkpath
      
      @rooted_path.chdir("relative_path").must_equal true
      @rooted_path.cwd.must_equal relative_path.parent.realpath
      
      @rooted_path.chdir("sub_path").must_equal true
      @rooted_path.cwd.must_equal relative_path.realpath
    end
    
    it "must allow you to use an absolute path" do
      absolute_path = @root + "absolute_path" + "sub_path"
      absolute_path.mkpath
      
      @rooted_path.chdir("/absolute_path").must_equal true
      @rooted_path.cwd.must_equal absolute_path.parent.realpath
      
      @rooted_path.chdir("/absolute_path/sub_path").must_equal true
      @rooted_path.cwd.must_equal absolute_path.realpath
    end
  end
end