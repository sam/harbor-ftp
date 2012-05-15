#!/usr/bin/env jruby

require_relative "../helper"

describe Harbor::FTP::UserManagers::SequelUserManager do
  
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
  
  describe "authorization" do
    
    it "should accept an default login" do
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
end