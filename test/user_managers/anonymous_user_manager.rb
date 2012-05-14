require "helper"
require "thread"
require "net/ftp"
require "fileutils"

describe Harbor::FTP::UserManagers::AnonymousUserManager do
  
  describe "authorization" do
  
    before do
      @home_directory = Pathname(__FILE__).dirname.parent.parent + "tmp" + "anonymous_user_manager_test"
      @server = Harbor::FTP::Server.new
      @server.user_manager.home_directory = @home_directory.to_s
      @server_thread = Thread.new { @server.start }
      sleep 0.1 # Give the server time to start up.
       
      FileUtils::mkdir @home_directory
      FileUtils::mkdir @home_directory + "samples"
      File::open(@home_directory + "samples" + "test.dat", "w+") do |file|
        file << Faker::Lorem::paragraphs
      end
    end
    
    after do
      Thread.kill(@server_thread)
      
      FileUtils::rmrf @home_directory
    end
    
    it "should accept an anonymous login" do
      Net::FTP.open("localhost:2121", "anonymous", "me@example.com") do |ftp|
        ftp.login
        files = ftp.chdir("samples")
        files = ftp.list('te*')
        
        files.must_include "test.dat"
        
        ftp.getbinaryfile("test.dat")
      end
    end
    
  end
  
  
end