#!/usr/bin/env jruby

require_relative "helper"

describe Harbor::FTP::Controller do

  before do
    class Example < Harbor::FTP::Controller
    end
  end
    
  it "should be available as a service" do
    Harbor::FTP::services.get("Example").must_be_kind_of(Example)
  end
  
  describe "verbs" do
    
    before do
      @example = Harbor::FTP::services.get("Example")
    end
    
    def self.specify_verb(verb)
      it "should respond to #{verb}" do
        Example.must_respond_to verb        
      end
    end
    
    [
      :stor,
      :list
    ].each { |verb| specify_verb(verb) }
    
  end
  
end