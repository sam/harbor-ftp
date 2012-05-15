require "helper"

describe Harbor::FTP::UserManagers::SequelUserManager::User do
  
  before do
    @user = Harbor::FTP::UserManagers::SequelUserManager::User.spawn
  end
  
  describe "contracted fields" do
    it "must have a password" do
      @user.must_respond_to :password
    end
    
    it "must have a ftp_username" do
      @user.must_respond_to :ftp_username
    end
    
    it "must have a ftp_home_directory" do
      @user.must_respond_to :ftp_home_directory
    end
  end
end