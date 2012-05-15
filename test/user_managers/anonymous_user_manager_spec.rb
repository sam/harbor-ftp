#!/usr/bin/env jruby

require_relative "../helper"

describe Harbor::FTP::UserManagers::AnonymousUserManager do
  
  before do
    @user_manager = Harbor::FTP::UserManagers::AnonymousUserManager.new
    @server = Helper::FTP::Server.new(@user_manager).start
    @user_manager.home_directory = @server.home_directory.to_s
  end
  
  after do
    @server.stop
  end
  
  describe "authorization" do
    
    it "should accept an anonymous login" do
      Helper::ftp("anonymous:me%40example.com@localhost:#{@server.port}") do |connection|
        connection.chdir("samples")
        connection.list('te*').join("\n").must_match /test.dat/
      end
    end # it
    
    it "should download a test file" do
      tmp = "/tmp/test.dat"
      Helper::ftp("anonymous:me%40example.com@localhost:#{@server.port}") do |connection|
        connection.chdir("samples")
        connection.getbinaryfile("test.dat", tmp)
        connection.size("test.dat").must_equal(File::size(tmp))
      end
    end
  end
end