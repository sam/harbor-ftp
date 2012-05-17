#!/usr/bin/env jruby

# If you haven't reviewed the examples/standalone-server.rb example yet,
# stop now and go do that. For brevity's sake I'm not going to repeat
# explanations for the basics here.

require "bundler/setup"
require "harbor/ftp"
require "bcrypt"

#### BEGIN: Database Setup...
# 
# We're going to use the very amazing Sequel (http://sequel.rubyforge.org)
# library for our example.
require "sequel"
DB = Sequel.connect("jdbc:h2:mem:")

# Let's create a users table real quick. We'll
# assume you're using BCrypt (http://bcrypt-ruby.rubyforge.org) to keep
# your passwords secure.
DB.create_table?(:users) do
  String :email, primary_key: true
  String :password_hash, null: true
  String :ftp_home_directory, default: "/tmp"
end
DB[:users].truncate

class User < Sequel::Model
  # We're using "email" as our Natural Primary Key,
  # so we need to tell Sequel to open it up for assignment.
  unrestrict_primary_key
  
  # Harbor::FTP::UserAdapter requires us to provide
  # an ftp_username, so let's alias our primary key.
  alias_method :ftp_username, :email
  
  ## BEGIN: BCrypt related functionality...
  include BCrypt

  # As long as the object returned by User#password
  # responds to #== and takes a plain-text-password
  # as the comparison value, Harbor::FTP::UserAdapter
  # will be happy. So wether you're storing a plain-
  # text-password in your database and this is just
  # a String, or you return a BCrypt::Password like
  # below, you've satisfied the contract demanded.
  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
  ## END: ...BCrypt related functionality
end
#### END: ...Database Setup

import org.apache.log4j.Logger
import org.apache.log4j.BasicConfigurator
BasicConfigurator.configure

server = Harbor::FTP::Server.new
server.port = 2121

require "harbor/ftp/user_managers/sequel_user_manager"
# We need to pass our User object to the SequelUserManager
# so it knows to use our own model, and not the built-in
# stub that it would use by default,
# (which really only exists for quick boot-strapping).
server.user_manager = Harbor::FTP::UserManagers::SequelUserManager.new(User)

# Now we'll add an account so we can login.
User.create(email: "me@example.com", password: "secret")

server.start