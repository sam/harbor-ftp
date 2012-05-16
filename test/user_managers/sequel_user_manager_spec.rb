#!/usr/bin/env jruby

require_relative "../helper"
require "bcrypt"

describe Harbor::FTP::UserManagers::SequelUserManager do
  
  describe "authorization" do
    
    User = Harbor::FTP::UserManagers::SequelUserManager::User

    before do              
      @user_manager = Harbor::FTP::UserManagers::SequelUserManager.new(User)
      @server = Helper::FTP::Server.new(@user_manager).start

      FileUtils::mkdir(@server.home_directory + "bob")
      File::open(@server.home_directory + "bob" + "secrets.txt", "w+") do |file|
        file << Faker::Lorem::paragraphs
      end

      User.create name: "Bob",
        email: "bob@example.com",
        password: "secret",
        ftp_home_directory: (@server.home_directory + "bob")

      FileUtils::mkdir(@server.home_directory + "lists")
      File::open(@server.home_directory + "lists" + "shopping.txt", "w+") do |file|
        file << Faker::Lorem::paragraphs
      end

      User.create name: "Sam",
        email: "sam@example.com",
        password: "if wishes were fishes",
        ftp_home_directory: @server.home_directory
    end

    after do
      @server.stop
      User.truncate
    end
    
    it "should accept a default login" do
      Helper::ftp("bob%40example.com:secret@localhost:#{@server.port}") do |connection|
        connection.list('s*').join("\n").must_match /secrets.txt/
      end
    end # it
    
    it "should download a test file" do
      tmp = "/tmp/test.dat"
      Helper::ftp("bob%40example.com:secret@localhost:#{@server.port}") do |connection|
        connection.getbinaryfile("secrets.txt", tmp)
        connection.size("secrets.txt").must_equal(File::size(tmp))
      end
    end
    
    it "should authorize sam in a different home directory" do      
      Helper::ftp("sam%40example.com:if+wishes+were+fishes@localhost:#{@server.port}") do |connection|
        connection.chdir("lists")
        connection.list('s*').join("\n").must_match /shopping.txt/
      end
    end
  end
  
  describe "custom User model" do
    
    module BCrypted
      class User < Sequel::Model(:bcrypted_users)
        
        unrestrict_primary_key
    
        def ftp_username
          email
        end
        
        include BCrypt

        def password
          @password ||= Password.new(password_hash)
        end

        def password=(new_password)
          @password = Password.create(new_password)
          self.password_hash = @password
        end
      end
    end
    
    before do              
      @user_manager = Harbor::FTP::UserManagers::SequelUserManager.new(BCrypted::User)
      @server = Helper::FTP::Server.new(@user_manager).start

      FileUtils::mkdir(@server.home_directory + "fred")
      File::open(@server.home_directory + "fred" + "home.jpg", "w+") do |file|
        file << Faker::Lorem::paragraphs
      end

      BCrypted::User.create email: "fred@example.com",
        password: "hash3y",
        ftp_home_directory: (@server.home_directory + "fred")
    end

    after do
      @server.stop
      BCrypted::User.truncate
    end
    
    it "should be able to authenticate a with a BCrypted password" do
      tmp = "/tmp/home.jpg"
      Helper::ftp("fred%40example.com:hash3y@localhost:#{@server.port}") do |connection|
        connection.getbinaryfile("home.jpg", tmp)
        connection.size("home.jpg").must_equal(File::size(tmp))
      end
    end
    
  end
end