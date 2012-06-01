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
      run_single_spec match[1]
    end
    
    # When a lib file changes, attempt to run the matching spec.
    script.watch( "lib/harbor/ftp/(.*)\.rb" ) do |match|
      run_single_spec match[1]
    end

    Watchr::Controller.new(script, Watchr.handler.new).run
  end
  
  private

  def run_single_spec(underscored_name)
    puts "\n#{Time.now.to_i} #{"#" * 69}\n"
    
    spec = Pathname("test/#{underscored_name}_spec.rb")
    
    if spec.exist?
      org.jruby.Ruby.newInstance.executeScript <<-RUBY, spec.to_s
        require "#{spec}"
        MiniTest::Unit.new._run
      RUBY
    else
      puts "No matching spec for #{spec}"
    end
    
    puts "#{"*" * 80}\n"
  end
  
  def run_all_specs
    puts "\n --- Running all specs ---\n\n"
    org.jruby.Ruby.newInstance.executeScript <<-RUBY, "all-specs"
      Dir["test/**/*_spec.rb"].each { |file| require file }
      MiniTest::Unit.new._run
    RUBY
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