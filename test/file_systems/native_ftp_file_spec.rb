#!/usr/bin/env jruby

require_relative "../helper"

describe Harbor::FTP::FileSystems::NativeFtpFile do

  NativeFtpFile = Harbor::FTP::FileSystems::NativeFtpFile
  
  before do
    (@home = Pathname(__FILE__).dirname.parent.parent + "tmp" + "native_ftp_file").mkpath
    @home = @home.realpath
    (@path = @home + "a").mkpath
    
    @bob = OpenStruct.new ftp_username: "bob", ftp_home_directory: @home.to_s, ftp_max_idle_time: 60
    @user = Harbor::FTP::UserAdapter.new(@bob)
  end
  
  after do
    @home.rmtree
  end
  
  
  describe "removable?" do
    it "must not allow home-directory to be removed" do      
      NativeFtpFile.new("/", java.io.File.new(@home.to_s), @user).removable?.must_equal false
    end
    
    it "must allow a sub-path to be removed if the parent is writable" do
      NativeFtpFile.new("/", java.io.File.new(@home.to_s), @user).writable?.must_equal true      
      NativeFtpFile.new("/a", java.io.File.new(@path.to_s), @user).removable?.must_equal true
    end
  end
  
  describe "get_absolute_path" do
    it "must be relative to the home-directory" do
      NativeFtpFile.new("/a", java.io.File.new(@path.to_s), @user).get_absolute_path.must_equal "/a"
    end
  end
  
  describe "basename" do
    it "should return just the file or directory name" do
      NativeFtpFile.new("/a", java.io.File.new(@path.to_s), @user).basename.must_equal "a"
      b_txt = @path.touch "b.txt"
      NativeFtpFile.new("/a/b.txt", java.io.File.new(b_txt.to_s), @user).basename.must_equal "b.txt"
    end
  end
  
  describe "list_files" do
    it "should return files with paths that are relative to root" do
      a = @path
      (b = @home + "b").mkpath
      (c = @home + "c").mkpath
      
      paths = [ a, b, c ].map { |path| "/#{path.relative_path_from(@home).to_s}" }
      home = NativeFtpFile.new("/", java.io.File.new(@home.to_s), @user)
      files = home.list_files
      files.size.must_equal 3
      files.map do |file|
        paths.must_include file.get_absolute_path
      end
    end
  end
end