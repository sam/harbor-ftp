#!/usr/bin/env jruby

require_relative "helper"

describe Harbor::FTP::Route do

  it "has a path class-method" do
    Harbor::FTP::Route.must_respond_to :path
  end
  
  it "has a cow class-method" do
    # p Harbor::FTP::Route.methods.sort
    Harbor::FTP::Route.must_respond_to :cow
  end
end