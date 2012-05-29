#!/usr/bin/env jruby

require_relative "../helper"

describe Harbor::FTP::FileSystems::NativeFtpFile do
  
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
      Harbor::FTP::FileSystems::NativeFtpFile.new("/", java.io.File.new(@home.to_s), @user).removable?.must_equal false
    end
    
    it "must allow a sub-path to be removed if the parent is writable" do
      Harbor::FTP::FileSystems::NativeFtpFile.new("/", java.io.File.new(@home.to_s), @user).writable?.must_equal true      
      Harbor::FTP::FileSystems::NativeFtpFile.new("/a", java.io.File.new(@path.to_s), @user).removable?.must_equal true
    end
  end
  
  describe "get_absolute_path" do
    it "must be relative to the home-directory" do
      Harbor::FTP::FileSystems::NativeFtpFile.new("/a", java.io.File.new(@path.to_s), @user).get_absolute_path.must_equal "/a"
    end
  end
  
  describe "basename" do
    it "should return just the file or directory name" do
      Harbor::FTP::FileSystems::NativeFtpFile.new("/a", java.io.File.new(@path.to_s), @user).basename.must_equal "a"
      b_txt = @path.touch "b.txt"
      Harbor::FTP::FileSystems::NativeFtpFile.new("/a/b.txt", java.io.File.new(b_txt.to_s), @user).basename.must_equal "b.txt"
    end
  end
  
  describe "list_files" do
    it "should return files with paths that are relative to root" do
      a = @path
      (b = @home + "b").mkpath
      (c = @home + "c").mkpath
      
      paths = [ a, b, c ].map { |path| "/#{path.relative_path_from(@home).to_s}" }
      home = Harbor::FTP::FileSystems::NativeFtpFile.new("/", java.io.File.new(@home.to_s), @user)
      files = home.list_files
      files.size.must_equal 3
      files.map do |file|
        paths.must_include file.get_absolute_path
      end
    end
  end
  
  describe "writable?" do
    it "should default to true using the default UserAdapter" do
      Harbor::FTP::FileSystems::NativeFtpFile.new("/", java.io.File.new(@home.to_s), @user).writable?.must_equal true
    end
  end
  
  describe "interface defaults" do
    before do
      @file = Harbor::FTP::FileSystems::NativeFtpFile.new("/", java.io.File.new(@home.to_s), @user)
    end
    
    describe "get_owner_name" do
      it "must return 'user'" do
        @file.get_owner_name.must_equal "user"
      end
    end
    
    describe "get_group_name" do
      it "must return 'group'" do
        @file.get_group_name.must_equal "group"
      end
    end
    
    describe "get_link_count" do
      it "must return 1 for a file" do
        txt = @home.touch "a.txt"
        Harbor::FTP::FileSystems::NativeFtpFile.new("/a.txt", java.io.File.new(txt.to_s), @user).get_link_count.must_equal 1
      end
      
      it "must return 3 for a directory" do
        @file.get_link_count.must_equal 3
      end
    end
    
    describe "size" do
      it "must return 0 for an empty file" do
        txt = @home.touch "a.txt"
        Harbor::FTP::FileSystems::NativeFtpFile.new("/a.txt", java.io.File.new(txt.to_s), @user).size.must_equal 0
      end
      
      it "must return the correct number of bytes for a non-empty file" do
        txt = @home + "a.txt"
        lorem = Faker::Lorem.paragraphs.join("\n")
        txt.open('w') { |io| io << lorem }
        
        Harbor::FTP::FileSystems::NativeFtpFile.new("/a.txt", java.io.File.new(txt.to_s), @user).size.must_equal lorem.bytesize
      end
    end
    
    describe "get_last_modified" do
      it "must return the correct datetime" do
        txt = @home.touch "a.txt"
        file = Harbor::FTP::FileSystems::NativeFtpFile.new("/a.txt", java.io.File.new(txt.to_s), @user)
        # java.io.File.lastModified() returns ms since epoch instead of Ruby's s.
        Time.at(file.last_modified/1000).must_equal txt.mtime
      end
    end
    
    describe "delete" do
      it "must remove file" do
        txt = @home.touch "a.txt"
        file = Harbor::FTP::FileSystems::NativeFtpFile.new("/a.txt", java.io.File.new(txt.to_s), @user)
        file.delete.must_equal true
        txt.exist?.must_equal false
      end
    end
    
    describe "mkdir" do
      it "must create directory" do
        zed = @home + "zed"
        file = Harbor::FTP::FileSystems::NativeFtpFile.new("/zed", java.io.File.new(zed.to_s), @user)
        
        zed.exist?.must_equal false
        file.mkdir.must_equal true
        zed.exist?.must_equal true
      end
    end
    
    describe "equals" do
      it "must be true if both share the same canonical path" do
        file1 = Harbor::FTP::FileSystems::NativeFtpFile.new("/", java.io.File.new(@home.to_s), @user)
        file2 = Harbor::FTP::FileSystems::NativeFtpFile.new("/", java.io.File.new(@home.to_s), @user)
        file1.must_equal file2
      end
    end
    
    describe "file" do
      it "must return a java.io.File" do
        txt = @home.touch "a.txt"
        a = Harbor::FTP::FileSystems::NativeFtpFile.new("/a.txt", java.io.File.new(txt.to_s), @user)
        a.file.must_be_kind_of java.io.File
        a.file.canonical_path.must_equal txt.realpath.to_s
      end
    end
    
    describe "hash" do
      it "must return the hash-code of the underlying java.io.File's canonical path" do
        txt = @home.touch "a.txt"
        a = Harbor::FTP::FileSystems::NativeFtpFile.new("/a.txt", java.io.File.new(txt.to_s), @user)
        a.hash.must_equal a.file.canonical_path.hash
      end
    end
    
    describe "move" do
      it "must move the file to a new location" do
        a = @home.touch "a.txt"
        (@home + "b").mkpath
        b = @home + "b" + "a.txt"
        file1 = Harbor::FTP::FileSystems::NativeFtpFile.new("/a.txt", java.io.File.new(a.to_s), @user)
        file2 = Harbor::FTP::FileSystems::NativeFtpFile.new("/b/a.txt", java.io.File.new(b.to_s), @user)

        a.exist?.must_equal true
        b.exist?.must_equal false
        file1.move(file2).must_equal true
        a.exist?.must_equal false
        b.exist?.must_equal true
      end
    end
    
    describe "last_modified=" do
      it "should update the file's mtime" do
        txt = @home.touch "a.txt"
        a = Harbor::FTP::FileSystems::NativeFtpFile.new("/a.txt", java.io.File.new(txt.to_s), @user)
        original_mtime = txt.mtime.to_i
        past = original_mtime - 10000
        
        a.last_modified = (past * 1000)

        txt.mtime.to_i.wont_equal original_mtime
        a.last_modified.wont_equal(original_mtime * 1000)
        
        txt.mtime.to_i.must_equal past
        a.last_modified.must_equal(past * 1000)
      end
    end
  end
end

#         def create_output_stream(offset)
#           raise java.io.IOException.new("No write permission : #{@file.name}") unless writable?
#           FileOutputStream.new(@file, offset)
#         end
# 
#         def create_input_stream(offset)
#           raise java.io.IOException.new("No read permission : #{@file.name}") unless readable?          
#           FileInputStream.new(@file, offset)
#         end