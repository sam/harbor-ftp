#!/usr/bin/env jruby

require "java"
require "rubygems"
require "bundler/setup" unless Object::const_defined?("Bundler")

require "listen"

class Watcher
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
    listener = Listen.to("test", "lib")
      .filter(/\.rb$/)
      .change do |modified, added, removed|
      modified.each do |path|
        # Because the ignore feature on Listener seems to
        # not work...
        next unless path =~ /\/(lib\/.*|test\/.*_spec)\.rb$/
        
        run_single_spec Pathname(path).basename(".rb").sub(/_spec$/, "")
      end
    end
    
    puts "Listening for changes..."
    listener.start
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
end

Watcher.new.run