#!/usr/bin/env jruby

require "bundler/setup"
require "harbor/ftp"
require "csv"

import org.apache.log4j.Logger
import org.apache.log4j.BasicConfigurator

# This basic logging configuration
# will output details to STDOUT.
BasicConfigurator.configure

server = Harbor::FTP::Server.new
# Set this to whatever you want.
# On most systems you'll need to be root to run
# on a privileged port like 21 however.
server.port = 2121

user_manager = Harbor::FTP::UserManagers::HashUserManager.new

# Let's assume we're loading a CSV file:
CSV::parse(DATA) do |row|
  user_manager.add_user row[0], row[1], row[2]
end

# Now assign the user_manager to the server so it'll use it
# to authorize your users.
server.user_manager = user_manager

# Unless you specifically background it in a Thread,
# the server is blocking, so this is all you need to do.
server.start

__END__
sam,secret,/Users/home/sam/ftp
bob,secret,/Users/home/bob/ftp
fred,funky,/tmp