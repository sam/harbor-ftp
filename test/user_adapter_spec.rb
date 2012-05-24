#!/usr/bin/env jruby

require_relative "helper"
require "ostruct"

describe Harbor::FTP::UserAdapter do
  
  before do
    @bob = OpenStruct.new ftp_username: "bob", ftp_home_directory: "/tmp", ftp_max_idle_time: 60
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
      bob = OpenStruct.new ftp_username: "bob", ftp_home_directory: "/tmp"
      user = Harbor::FTP::UserAdapter.new(bob)
      user.max_idle_time.must_equal 0
    end
    
    it "must not be nil" do
      @user.max_idle_time = nil
      @user.max_idle_time.must_equal 0
    end
    
    it "must accept a Fixnum or nil exclusively" do
      @user.max_idle_time = nil
      @user.max_idle_time = 100
      assert_raises(ArgumentError) do
        @user.max_idle_time = "over nine thousand!"
      end
    end
  end
  
  describe "new_with_timeout" do    
    it "user non-zero values always take precedence" do
      @bob.ftp_max_idle_time.must_equal 60
      
      user = Harbor::FTP::UserAdapter.new_with_timeout(@bob, 300)
      user.max_idle_time.must_equal 60
      
      user = Harbor::FTP::UserAdapter.new_with_timeout(@bob, 30)
      user.max_idle_time.must_equal 60
    end
    
    it "unlimited users are limited by the server" do
      @bob.ftp_max_idle_time = 0
      user = Harbor::FTP::UserAdapter.new_with_timeout(@bob, 300)
      user.max_idle_time.must_equal 300
    end
  end
  
  describe "wrapped values" do
    before do
      @mock = MiniTest::Mock.new
      @mock.expect :ftp_username, "bob"
      @mock.expect :ftp_home_directory, "/root"
      
      @user = Harbor::FTP::UserAdapter.new(@mock)
    end
    
    describe "name" do
      it "should be set by ftp_username method on the wrapped User" do
        @mock.verify
        @user.name.must_equal "bob"
      end
    end
    
    describe "home_directory" do
      it "should be set by ftp_home_directory method on the wrapped User" do
        @mock.verify
        @user.home_directory.must_equal "/root"
      end
    end
  end
  
  describe "new_with_timeout" do
    it "must be a constructor" do
      Harbor::FTP::UserAdapter.must_respond_to(:new_with_timeout)
    end
  end
end