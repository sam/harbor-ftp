require "helper"

describe Harbor::FTP::UserManagers::SequelUserManager::User do
  
  before do
    @user = Harbor::FTP::UserManagers::SequelUserManager::User.spawn
  end
  
  describe "fields" do
    it "must have a email" do
      @user.must_respond_to :email
    end
  end
end