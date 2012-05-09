#!/usr/bin/env jruby

require "java"

jars = File.join(File.dirname(__FILE__), "apache-ftpserver-1.0.6", "common", "lib", "*.jar")
Dir[jars].each { |jar| require jar }

# Setup your login:
import org.apache.ftpserver.ftplet.User
import org.apache.ftpserver.ftplet.UserManager
import org.apache.ftpserver.usermanager.PropertiesUserManagerFactory
import org.apache.ftpserver.usermanager.ClearTextPasswordEncryptor
import org.apache.ftpserver.usermanager.UserFactory

user_manager_factory = PropertiesUserManagerFactory.new
user_manager_factory.password_encryptor = ClearTextPasswordEncryptor.new

user_manager = user_manager_factory.create_user_manager

user_factory = UserFactory.new
user_factory.name = "me"
user_factory.password = "secret"
user_factory.home_directory = File.dirname(__FILE__)
user = user_factory.create_user

user_manager.save user

# Setup your server:
import org.apache.ftpserver.FtpServer
import org.apache.ftpserver.FtpServerFactory
import org.apache.ftpserver.listener.ListenerFactory

server_factory = FtpServerFactory.new
listener_factory = ListenerFactory.new

listener_factory.port = 2221

server_factory.user_manager = user_manager
server_factory.add_listener "default", listener_factory.create_listener

server = server_factory.create_server

# Start the server
server.start