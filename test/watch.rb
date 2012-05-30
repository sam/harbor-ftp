#!/usr/bin/env jruby

require_relative "helper"
require "watchr"

def all_spec_files
  Dir["test/**/*_spec.rb"]
end

def run_all_specs
  # It would be nice if this could just Kernel::load all files instead, and call
  # Minitest::Unit::run, but loading the specs causes them to be re-added multiple
  # times. There's no Set of specifications, so I'd have to figure out how to clear
  # the registered specs first.
  puts "\n --- Running all specs ---\n\n"
  system("jruby -e'%w( #{all_spec_files.join(' ')} ).each {|file| require file }'")
end

def run_single_spec(name)
  spec = Pathname("test/#{name}_spec.rb")
  if spec.exist?
    puts "\n\nRunning spec for #{name}..."
    system("jruby #{spec}")
  else
    puts "\n\nNo matching spec for #{name}.rb."
  end
end

interrupted = false

# Ctrl-C
# Hit it twice in quick succession to exit the program.
Signal.trap("INT") do
  if interrupted
    puts
    puts "Shutting down..."
    exit
  else
    interrupted = true
    run_all_specs
    interrupted = false
  end
end

script = Watchr::Script.new
# Run an individual spec when it changes. Again, would be nice to be able to
# load and execute instead of firing up a separate process.
script.watch( "test/(.*)_spec\.rb" )         { |match| run_single_spec match[1] }
# When a lib file changes, attempt to run the matching spec.
script.watch( "lib/harbor/ftp/(.*)\.rb" )  { |match| run_single_spec match[1] }

Watchr::Controller.new(script, Watchr.handler.new).run