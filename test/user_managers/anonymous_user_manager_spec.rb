#!/usr/bin/env jruby

require_relative "../helper"
require "fileutils"

describe Harbor::FTP::UserManagers::AnonymousUserManager do
  
  describe "authorization" do
  
    before do
      @home_directory = Pathname(__FILE__).dirname.parent.parent + "tmp" + "anonymous_user_manager_test"
    
      FileUtils::rm_rf @home_directory if File.exists?(@home_directory)
      FileUtils::mkdir @home_directory
      FileUtils::mkdir @home_directory + "samples"
      File::open(@home_directory + "samples" + "test.dat", "w+") do |file|
        file << Faker::Lorem::paragraphs
      end
    
      @server = Harbor::FTP::Server.new
      @server.port = Helper::next_port
      @server.user_manager.home_directory = @home_directory.to_s
      @server_thread = Thread.new { @server.start }
      sleep 0.5 # Give the server time to start up.
    end
    
    after do
      @server.stop
      Thread.kill(@server_thread)
    
      FileUtils::rm_rf @home_directory
    end
    
    it "should accept an anonymous login" do
      Helper::ftp("anonymous:me%40example.com@localhost:#{@server.port}") do |connection|
        connection.chdir("samples")
        connection.list('te*').join("\n").must_match /test.dat/
      end
    end # it
    
    # it "should download a test file" do
    #   skip
    #   ftp.getbinaryfile("test.dat")
    # end
  end
end