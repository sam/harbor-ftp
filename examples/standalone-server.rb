#!/usr/bin/env jruby

require "bundler/setup"
require "harbor/ftp"
require "csv"

server = Harbor::FTP::Server.new
# Set this to whatever you want.
# On most systems you'll need to be root to run
# on a privileged port like 21 however.
server.port = 2121

# Let's create a UserManager so we can add users to
# our server, set their passwords, home-directories, etc.
user_manager = Harbor::FTP::UserManagers::HashUserManager.new

# Let's assume we're loading a CSV file:
CSV::parse(DATA) do |row|
  user_manager.add_user row[0], row[1], row[2]
end
# NOTE: If you added an "anonymous" user, then the server
# would allow anonymous logins. That's actually all the
# AnonymousUserManager does. It inherits from HashUserManager,
# and adds an "anonymous" user during initialization.

# Now assign the user_manager to the server so it'll use it
# to authorize your users.
server.user_manager = user_manager

# I'm a right bastard, so I'm going to set everyone's
# idle disconnect time to just sixty seconds.
server.timeout = 60

# Unless you specifically background it in a Thread,
# the server is blocking, so this is all you need to do.
server.start

__END__
sam,secret,/Users/sam
bob,secret,/Users/bob
fred,funky,/tmp