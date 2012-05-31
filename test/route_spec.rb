#!/usr/bin/env jruby

require_relative "helper"

describe Harbor::FTP::Route do

  it "has a path class-method" do
    Harbor::FTP::Route.must_respond_to :path
  end
  
  it "has a cow class-method" do
    Harbor::FTP::Route.must_respond_to :cow
  end
end

# # This is just the basics to show you what the Apache FtpServer
# # is going to provide for any general Command receipt.
# class Harbor::FTP::Controller
#   attr_reader :context, :request, :user
#   def initialize(context, request, user)
#     @context, @request, @user = context, request, user
#   end
# end
# 
# # If you want to provide a custom handler for displaying
# # a dynamic "directory" after receiving a LIST command,
# # then you also need to handle how you're going to respond
# # when a user submits a GET command for a file in that
# # "directory". You also need to decide what to do when
# # a user submits a PUT command to upload a file to that
# # "directory". So these three operations don't exist
# # individually in a vacuum. You must handle them all.
# #
# # So it makes sense then that a Controller is a
# # representation of a particular Route. In fact,
# # I may rename it to Harbor::FTP::Route to better
# # reflect that.
# class ChannelsController < Harbor::FTP::Controller
#   
#   # Here we pin the actual (wild-card capable) route
#   # for this Controller.
#   route "/channels/:path"
#   
#   # Now we must implement our three commands,
#   # list, stor and get. These methods will recieve
#   # any named paramters you defined in your route
#   # through the magic of Ruby 1.9 Method#parameters.
#   
#   # stor will additionally recieve a temporary file.
#   # It will probably be a Pathname instance, so you
#   # can easily open, modify, retrieve the actual path, etc.
#   def stor(path, file)
#     # Just pretending that we have some place to put this.
#     # Not important.
#     AssetServer::put_by_path(path, file)
#   end
#   
#   # A flawed example implementation. Assume that
#   # Channel#children_and_assets returns Channel#children
#   # (that we'll display as Directories)
#   # as well as Channel#releases, Channel#photos,
#   # Channel#videos, whatever "content" is availble to display
#   # as files. Maybe as simple as:
#   #
#   #   {
#   #     directories: [ 
#   #       "model1", "model2", "model3"
#   #     ],
#   #     files: [
#   #       "photo1", "photo2", "video1", "release1"
#   #     ]
#   #   }
#   #
#   # You'll always LIST a directory, so we don't have to
#   # worry about wether +path+ is a file or directory.
#   def list(path)
#     channel = DB[:channels].first(:name => path.split.first)
#     path.split[1..-1].each do |name|
#       channel = channel.children.first(:name => name)
#     end
#     
#     channel.children_and_assets.to_json
#   end
#   
#   # Here we'll just get the +path+, which will always be
#   # a file since you can't GET a directory.
#   def get(path)
#     AssetServer::get_by_path(path)
#   end
# end