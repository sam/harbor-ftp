#!/usr/bin/env jruby

require_relative "../helper"
require "harbor/ftp/user_managers/sequel_user_manager"
require "bcrypt"

describe Harbor::FTP::UserManagers::SequelUserManager do
  
  describe "authorization with custom key-field" do

    before do
      
      DB.create_table :users do
        String :name, primary_key: true
        String :password, null: false
        String :ftp_home_directory, default: "/tmp"
      end
      
      user = Class.new(Sequel::Model(:users)) do
        unrestrict_primary_key
        alias_method :ftp_username, :name
      end
      
      @user_manager = Harbor::FTP::UserManagers::SequelUserManager.new(user, :name)
      @server = Helper::FTP::Server.new(@user_manager).start

      FileUtils::mkdir(@server.home_directory + "bob")
      File::open(@server.home_directory + "bob" + "secrets.txt", "w+") do |file|
        file << Faker::Lorem::paragraphs
      end

      user.create name: "Bob",
        password: "secret",
        ftp_home_directory: (@server.home_directory + "bob")

      FileUtils::mkdir(@server.home_directory + "lists")
      File::open(@server.home_directory + "lists" + "shopping.txt", "w+") do |file|
        file << Faker::Lorem::paragraphs
      end

      user.create name: "Sam",
        password: "if wishes were fishes",
        ftp_home_directory: @server.home_directory
    end

    after do
      @server.stop
      DB.drop_table :users
    end
    
    it "should accept a default login" do
      Helper::ftp("Bob:secret@localhost:#{@server.port}") do |connection|
        connection.list('s*').join("\n").must_match /secrets.txt/
      end
    end # it
    
    it "should download a test file" do
      tmp = "/tmp/test.dat"
      Helper::ftp("Bob:secret@localhost:#{@server.port}") do |connection|
        connection.getbinaryfile("secrets.txt", tmp)
        connection.size("secrets.txt").must_equal(File::size(tmp))
      end
    end
    
    it "should authorize sam in a different home directory" do      
      Helper::ftp("Sam:if+wishes+were+fishes@localhost:#{@server.port}") do |connection|
        connection.chdir("lists")
        connection.list('s*').join("\n").must_match /shopping.txt/
      end
    end
  end
  
  describe "custom User model" do
    
    before do
      DB.create_table :users do
        String :email, primary_key: true
        String :password_hash, null: true
        String :ftp_home_directory, default: "/tmp"
      end
      
      user = Class.new(Sequel::Model(:users)) do
        unrestrict_primary_key
        alias_method :ftp_username, :email
        
        def password
          @password ||= BCrypt::Password.new(password_hash)
        end

        def password=(new_password)
          @password = BCrypt::Password.create(new_password)
          self.password_hash = @password
        end
      end
      
      @user_manager = Harbor::FTP::UserManagers::SequelUserManager.new(user)
      @server = Helper::FTP::Server.new(@user_manager).start

      FileUtils::mkdir(@server.home_directory + "fred")
      File::open(@server.home_directory + "fred" + "home.jpg", "w+") do |file|
        file << Faker::Lorem::paragraphs
      end

      user.create email: "fred@example.com",
        password: "hash3y",
        ftp_home_directory: (@server.home_directory + "fred")
    end

    after do
      @server.stop
      DB.drop_table :users
    end
    
    it "should be able to authenticate a with a BCrypted password" do
      tmp = "/tmp/home.jpg"
      Helper::ftp("fred%40example.com:hash3y@localhost:#{@server.port}") do |connection|
        connection.getbinaryfile("home.jpg", tmp)
        connection.size("home.jpg").must_equal(File::size(tmp))
      end
    end
    
    it "must be able to list all users" do
      users = @user_manager.get_all_user_names
      users.size.must_equal 1
      users.first.must_equal "fred@example.com"
    end
    
    it "must tell you if a user exists" do
      @user_manager.exists?("fred@example.com").must_equal true
    end
    
  end
end