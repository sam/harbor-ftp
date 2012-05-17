#!/usr/bin/env jruby

require_relative "helper"

describe Harbor::FTP::Container do

  before do
    @container = Harbor::FTP::Container.new
    @service = Class.new
  end
  
  describe "registering a service" do
    it "must allow a Class to be set" do
      @container.set("service", @service).must_equal @service
    end
    
    it "must allow a Class to be assigned through a named setter method" do
      (@container.service = @service).must_equal @service
    end
  end
  
  describe "registered component instantiation" do
    before do
      @container.set("service", @service)
    end
    
    it "must allow registered services to be retrieved by name" do
      @container.get("service").must_be_kind_of @service
    end
    
    it "should allow registered services to be retrieved through method names" do
      @container.service.must_be_kind_of @service
    end
    
    describe "components with dependencies" do
      def validate_business(business)
        @container.set("business", business)
        
        plumber = @container.business
        plumber.must_be_kind_of(business)
        plumber.service.must_be_kind_of(@service)
      end
      
      it "should allow setter based dependency injection" do
        business = Class.new do
          attr_accessor :service
        end
        
        validate_business(business)
      end
      
      it "should allow constructor based dependency injection" do
        business = Class.new do
          attr_reader :service
          
          def initialize(service)
            @service = service
          end
        end
        
        validate_business(business)
      end
    end
  end

end