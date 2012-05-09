#!/usr/bin/env jruby

require "java"

jars = File.join(File.dirname(__FILE__), "apache-ftpserver-1.0.6", "common", "lib", "*.jar")
Dir[jars].each { |jar| require jar }

import org.apache.ftpserver.FtpServer
import org.apache.ftpserver.FtpServerFactory
import org.apache.ftpserver.listener.ListenerFactory

server_factory = FtpServerFactory.new
listener_factory = ListenerFactory.new

listener_factory.port = 2221

server_factory.add_listener "default", listener_factory.create_listener

server = server_factory.create_server

# start the server
server.start
