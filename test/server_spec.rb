require "helper"
require "thread"

describe Harbor::FTP::Server do
  before do
    @server = Harbor::FTP::Server.new
  end
  
  describe "port" do
    it "must default to 21" do
      @server.port.must_equal 21
    end
    
    it "must be a Fixnum" do
      assert_raises(Harbor::FTP::Server::InvalidPortError) do
        @server.port = "one"
      end
    end
    
    it "must be greater than 1" do
      assert_raises(Harbor::FTP::Server::PortNotInRange) do
        @server.port = 1
      end
    end
    
    it "must be less than or equal to 65535" do
      assert_raises(Harbor::FTP::Server::PortNotInRange) do
        @server.port = 70000
      end
    end
    
    it "must accept a valid port" do
      @server.port = 2121
      @server.port.must_equal 2121
    end
    
    it "must not be able to change the port after the server is started" do
      @server.port = 2121
      thread = Thread.new { @server.start }
      sleep 0.1 # Ensure that the thread/server has time to start.
      
      assert_raises(Harbor::FTP::Server::RunningConfigurationChangeError) do
        @server.port = 4141
      end
      
      Thread.kill(thread)
    end
  end
  
  describe "user_manager" do
    it "must respond to a user_manager reader" do
      @server.must_respond_to :user_manager
    end
    
    it "must respond to a user_manager writer" do
      @server.must_respond_to :user_manager=
    end
    
    it "must default to nil" do
      @server.user_manager.must_be_nil
    end
  end
end