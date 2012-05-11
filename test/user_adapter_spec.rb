require "helper"

describe Harbor::FTP::UserAdapter do
  
  before do
    @bob = OpenStruct.new ftp_username: "bob", ftp_home_directory: "/tmp", max_idle_time: 60
    @user = Harbor::FTP::UserAdapter.new(@bob)
  end
  
  describe "enabled?" do
    it "must be true" do
      @user.enabled?.must_equal true
    end
  end
  
  describe "password" do
    it "must be nil" do
      @user.password.must_be_nil
    end
  end
  
  describe "max_idle_time" do
    it "must default to zero" do
      @user.max_idle_time.must_equal 0
    end
  end
  
  describe "ftp_username" do
    it "should be set by the wrapped User" do
      mock = MiniTest::Mock.new
      mock.expect :ftp_username, "bob"
      mock.expect :ftp_home_directory, "/root"
      
      user = Harbor::FTP::UserAdapter.new(mock)
      mock.verify
      user.name.must_equal "bob"
    end
  end
  
end

# class Harbor
#   module FTP
#     # This class is intended for internal use only, adapting your own simple
#     # User objects to the org.apache.ftpserver.ftplet.User interface.
#     class UserAdapter
#       
#       include org.apache.ftpserver.ftplet.User
#       
#       def initialize(user)
#         @name = user.ftp_username
#         @home_directory = user.ftp_home_directory
#         @authorities = []
#         @max_idle_time = user.respond_to?(:ftp_max_idle_time) ? user.ftp_max_idle_time : 0
#       end
#       
#       attr_accessor :name, :home_directory, :authorities, :max_idle_time
#       
#       def enabled?
#         true
#       end
#       
#       # We do not expose the password here since it's unnecessary and
#       # may not be available depending on your wrapped user's password
#       # implementation.
#       def password
#         nil
#       end
#       
#     end # class UserAdapter
#   end # module FTP
# end # class Harbor