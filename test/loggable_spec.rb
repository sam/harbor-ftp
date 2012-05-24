#!/usr/bin/env jruby

require_relative "helper"

describe Harbor::FTP::Loggable do
  describe "inclusion" do
    it "must define a private LOG constant" do
      class MyLoggedClass
        include Harbor::FTP::Loggable
      end
      
      MyLoggedClass.const_defined?(:LOG).must_equal true
    end
  end
end