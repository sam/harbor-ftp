require_relative "helper"

describe Harbor::FTP::Server do
  before do
    @server = Harbor::FTP::Server.new
  end
  
  describe "start/stop state" do
    it "should be stoppable" do
      @server.port = Helper::next_port
      @server.start
      assert @server.stop
    end

    it "should raise an error when stopping if not started" do
      assert_raises(Harbor::FTP::Server::ServerNotStartedError) do
        @server.stop
      end
    end
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
      @server.port = Helper::next_port
      thread = Thread.new { @server.start }
      sleep 0.5 # Ensure that the thread/server has time to start.
      
      assert_raises(Harbor::FTP::Server::RunningConfigurationChangeError) do
        @server.port = 4141
      end
      
      @server.stop
    end
  end
  
  describe "timeout" do
    it "must default to 300" do
      @server.timeout.must_equal 300
    end
    
    it "must be a Fixnum" do
      assert_raises(Harbor::FTP::Server::InvalidTimeoutError) do
        @server.timeout = "one"
      end
      
      assert_raises(Harbor::FTP::Server::InvalidTimeoutError) do
        @server.timeout = nil
      end
    end
    
    it "can be set to 0" do
      @server.timeout = 0
      @server.timeout.must_equal 0
    end
    
    it "must be able to change the timeout after the server is started" do
      @server.port = Helper::next_port
      Thread.new { @server.start }
      sleep 0.5 # Ensure that the thread/server has time to start.
      
      @server.timeout = 9000
      @server.timeout.must_equal 9000
      
      @server.stop
    end
  end
  
  describe "user_manager" do
    it "must respond to a user_manager reader" do
      @server.must_respond_to :user_manager
    end
    
    it "must respond to a user_manager writer" do
      @server.must_respond_to :user_manager=
    end
    
    it "must default to AnonymousUserManager" do
      @server.user_manager.must_be_kind_of(Harbor::FTP::UserManagers::AnonymousUserManager)
    end
    
    it "should require a UserManager instance" do
      assert_raises(ArgumentError) do
        @server.user_manager = "cow"
      end
    end
  end
end