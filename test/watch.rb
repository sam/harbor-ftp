#!/usr/bin/env jruby

require_relative "helper"
require "watchr"

class Watch

  def initialize
    @interrupted = false
    
    # Hit Ctrl-C once to re-run all specs; twice to exit the program.
    Signal.trap("INT") do
      if @interrupted
        puts "\nShutting down..."
        exit
      else
        @interrupted = true
        run_all_specs
        @interrupted = false
      end
    end
  end
  
  def run
    script = Watchr::Script.new
    
    # Run an individual spec when it changes.
    script.watch( "test/(.*)_spec\.rb" ) do |match|
      puts "\n#{Time.now.to_i} #{"#" * 69}\n"
      
      underscored_name = match[1]
      spec = Pathname("test/#{underscored_name}_spec.rb")
      
      if spec.exist?
        puts "Reloading #{spec}"
        # MiniTest::Spec::test_suites.each do |suite|
        #   suite.nuke_test_methods!
        # end
        MiniTest::Spec.reset
        load spec
        MiniTest::Unit.new._run
      else
        puts "No matching spec for #{spec}"
      end
      
      puts "#{"*" * 80}\n"
    end
    
    # When a lib file changes, attempt to run the matching spec.
    script.watch( "lib/harbor/ftp/(.*)\.rb" ) do |match|
      puts "\n#{Time.now.to_i} #{"#" * 69}\n"
      
      underscored_name = match[1]
      
      lib = Pathname("lib/harbor/ftp/#{underscored_name}.rb")
      if lib.exist?
        puts "Reloading #{lib}"
        remove_nested_const(underscored_name)
        load lib
      else
        puts "No matching lib for #{lib}"
      end

      spec = Pathname("test/#{underscored_name}_spec.rb")
      if spec.exist?
        puts "Reloading #{spec}"
        # MiniTest::Spec::test_suites.each do |suite|
        #   suite.nuke_test_methods!
        # end
        MiniTest::Spec.reset
        load spec
        MiniTest::Unit.new._run
      else
        puts "No matching spec for #{spec}"
      end
      
      puts "#{"*" * 80}\n"
    end

    Watchr::Controller.new(script, Watchr.handler.new).run
  end
  
  private

  def run_all_specs
    puts "\n --- Running all specs ---\n\n"
    MiniTest::Spec.reset
    Dir["test/**/*_spec.rb"].each { |file| load file }
    MiniTest::Unit.new._run
  end
  
  def remove_nested_const(name)
    fragments = name.classify.split("::")
    klass = fragments.pop
    parent = fragments.inject(Harbor::FTP) do |k,n|
      k.const_get(n)
    end
    parent.send(:remove_const, klass)
  end
    
end

Watch.new.run