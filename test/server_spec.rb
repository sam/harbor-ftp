require "helper"
require "thread"

describe Harbor::FTP::Server do
  before do
    @server = Harbor::FTP::Server.new
  end
  
  describe "port" do
    it "should default to 21" do
      @server.port.must_equal 21
    end
    
    it "should be a Fixnum" do
      assert_raises(Harbor::FTP::Server::InvalidPortError) do
        @server.port = "one"
      end
    end
    
    it "should be greater than 1" do
      assert_raises(Harbor::FTP::Server::PortNotInRange) do
        @server.port = 1
      end
    end
    
    it "should be less than or equal to 65535" do
      assert_raises(Harbor::FTP::Server::PortNotInRange) do
        @server.port = 70000
      end
    end
    
    it "should accept a valid port" do
      @server.port = 2121
      @server.port.must_equal 2121
    end
    
    it "should not be able to change the port after the server is started" do
      @server.port = 2121
      thread = Thread.new { @server.start }
      sleep 0.1 # Ensure that the thread/server has time to start.
      
      assert_raises(Harbor::FTP::Server::RunningConfigurationChangeError) do
        @server.port = 4141
      end
      
      Thread.kill(thread)
    end
  end
end