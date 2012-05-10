require "helper"

describe Harbor::FTP::User do
  
  before do
    @user = Harbor::FTP::User.spawn
  end
  
  describe "fields" do
    it "must have a email" do
      @user.must_respond_to :email
    end
  end
end