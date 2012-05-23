#!/usr/bin/env jruby

require_relative "../helper"

describe Harbor::FTP::FileSystems::NativeFileSystemFactory do
  
  before do
    @factory = Harbor::FTP::FileSystems::NativeFileSystemFactory.new
    @home_directory = Pathname(__FILE__).dirname.parent.parent + "tmp" + "native_file_system_factory_spec"
    FileUtils::mkdir_p @home_directory
  end
  
  after do
    FileUtils::rm_rf @home_directory
  end
  
  describe "create_home" do
    
    it "must return a boolean" do
      @factory.create_home?.must_equal false
    end
    
    it "must only allow boolean assignment" do
      @factory.create_home = true
      @factory.create_home?.must_equal true
      
      assert_raises(ArgumentError) do
        @factory.create_home = :cow
      end
    end
    
  end
  
  describe "case_insensitive" do
    it "must always return false" do
      @factory.case_insensitive?.must_equal false
    end
    
    it "has no writer" do
      assert_raises(NoMethodError) do
        @factory.case_insensitive = true
      end
    end
  end
  
  describe "create_file_system_view" do
    before do
      @user = Harbor::FTP::UserManagers::User.new "bob", "secret", @home_directory.to_s
      @user_adapter = Harbor::FTP::UserAdapter.new(@user)
    end
    
    it "must return a FileSystemView" do
      @factory.create_file_system_view(@user_adapter).must_be_kind_of org.apache.ftpserver.ftplet.FileSystemView
    end
    
    it "must not create a home_directory if it already exists" do
      test_file = (@home_directory + "do_not_touch.txt").to_s
      @factory.create_home = true
      
      FileUtils::touch test_file
      @factory.create_file_system_view(@user_adapter).must_be_kind_of org.apache.ftpserver.ftplet.FileSystemView
      File::exists?(test_file).must_equal true
    end
    
    it "must create home_directory if it does not exist and create_home is true" do
      @factory.create_home = true
      @user.ftp_home_directory = (@home_directory + "bob").to_s
      @user_adapter = Harbor::FTP::UserAdapter.new(@user)
      
      File::directory?(@user.ftp_home_directory).must_equal false
      @factory.create_file_system_view(@user_adapter).must_be_kind_of org.apache.ftpserver.ftplet.FileSystemView
      File::directory?(@user.ftp_home_directory).must_equal true
    end
  end
end