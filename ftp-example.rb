#!/usr/bin/env jruby

require "bundler/setup"
require "sequel"

Sequel.sqlite

server = Harbor::FTP::Server.new
server.start