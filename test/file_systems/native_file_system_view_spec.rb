#!/usr/bin/env jruby

require_relative "../helper"

describe Harbor::FTP::FileSystems::NativeFileSystemView do

  before do
    @home_directory = Pathname(__FILE__).dirname.parent.parent + "tmp" + "native_file_system_view"
    FileUtils::mkdir_p @home_directory

    @user = Harbor::FTP::UserManagers::User.new "bob", "secret", @home_directory.to_s
    @user_adapter = Harbor::FTP::UserAdapter.new(@user)

    @view = Harbor::FTP::FileSystems::NativeFileSystemView.new(@user_adapter)
  end
  
  after do
    FileUtils::rm_rf @home_directory
  end
  
  describe "case_insensitive" do
    it "must always return false" do
      @view.case_insensitive?.must_equal false
    end
  end
  
  describe "random_accessible" do
    it "must always return true" do
      @view.random_accessible?.must_equal true
    end
  end
  
  describe "home_directory" do
    it "must return a NativeFtpFile" do
      @view.home_directory.must_be_kind_of Harbor::FTP::FileSystems::NativeFtpFile
    end
    
    it "must default to the home_directory of the user" do
      @view.home_directory.get_absolute_path.must_equal "/"
    end
  end
  
  describe "working_directory" do
    it "must default to root" do
      @view.working_directory.get_absolute_path.must_equal "/"
    end    
  end
  
  it "must implement a dispose method" do
    @view.must_respond_to :dispose
  end
  
  describe "change_working_directory" do
    it "must chroot all requests" do
      @view.change_working_directory("/../").must_equal false
    end
    
    it "must allow you to request a relative path" do
      path = @home_directory + "a" + "b"
      path.mkpath
      
      @view.change_working_directory("a").must_equal true
      @view.change_working_directory("b").must_equal true
    end
    
    it "must allow you to request an absolute path" do
      path = @home_directory + "a" + "b"
      path.mkpath
      
      @view.change_working_directory("/a").must_equal true
      @view.change_working_directory("/a/b").must_equal true
    end
  end
  
  describe "get_file" do
    it "must return a NativeFtpFile" do
      path = @home_directory + "a"
      path.mkpath
    
      file = @view.get_file("a")
      file.must_be_kind_of Harbor::FTP::FileSystems::NativeFtpFile
      # TODO: What does "absolute_path" mean in this context?
      # Need to clarify this when specifying NativeFtpFile.
      file.get_absolute_path.must_equal path.realpath.to_s
    end
  end
end