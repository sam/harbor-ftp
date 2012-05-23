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
  
  describe "get_physical_name" do
    it "must return a chrooted path" do
      @view.get_physical_name("/../").must_equal @home_directory.realpath.to_s
    end
  end
  
  # 
  # class Harbor
  #   module FTP
  #     module FileSystems
  #       class NativeFileSystemView
  # 
  #         def home_directory
  #           NativeFtpFile.new "/", java.io.File.new(@root_dir.realpath.to_s), @user
  #         end
  # 
  #         def working_directory
  #           NativeFtpFile.new "/", java.io.File.new(@current_dir.realpath.to_s), @user
  #         end
  # 
  #         def get_file(path)
  #           LOG.debug { "get_file(\"#{path}\") :: @root_dir[#{@root_dir}]" }
  #           path = get_physical_name(path)
  #           LOG.debug { "PATH: #{path}" }
  # 
  #           file = java.io.File.new(path)
  # 
  #           NativeFtpFile.new path, file, @user
  #         end
  # 
  #         def change_working_directory(dir)
  #           LOG.debug { "change_working_directory(\"#{dir}\")" }
  #           dir = get_physical_name(dir)   
  # 
  #           if Pathname(dir).directory?
  #             @current_dir = Pathname(dir)
  #           else
  #             LOG.error { "dir does not exist! #{dir}" }
  #             return false
  #           end
  # 
  #           return true
  #         end
  # 
  #         def dispose
  #           nil
  #         end
  # 
  #         private
  # 
  #         LOG = RJack::SLF4J[self]
  # 
  #         def get_physical_name(path)
  #           path = if path.start_with? "/"
  #             (@root_dir + path).realpath.to_s
  #           else
  #             LOG.debug { "get_physical_name: relative_path: @root_dir: #{@root_dir} @current_dir: #{@current_dir} @path: #{path}" }
  #             (@current_dir + path).realpath.to_s
  #           end
  # 
  #           if path.start_with? @root_dir.realpath.to_s
  #             path
  #           else
  #             @root_dir.realpath.to_s
  #           end
  #         end
  # 
  #       end # class NativeFileSystemView
  #     end # module FileSystems
  #   end # module FTP
  # end # class Harbor
  
end