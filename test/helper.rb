require "rubygems"
require "bundler/setup" unless Object::const_defined?("Bundler")

require "faker"
require "sequel"

require "minitest/autorun"
require "minitest/pride"
require "minitest/wscolor"

$:.unshift (Pathname(__FILE__).dirname.parent + "lib").to_s
require "harbor/ftp"

require "sequel"
DB = Sequel.connect("jdbc:h2:mem:")

Sequel.extension :inflector

require "thread"
require "net/ftp"
require "uri"
require "cgi"
require "fileutils"

class Helper
  
  @semaphore = Mutex.new
  
  def self.semaphore
    @semaphore
  end
  
  def self.next_port
    @semaphore.synchronize do
      @port = (@port || 0) + 2121
    end
  end
  
  def self.ftp(uri)
    uri = if uri =~ /^ftp:\/\//
      URI::parse(uri)
    else
      URI::parse("ftp://#{uri}")
    end

    connection = Net::FTP.new
    connection.connect CGI::unescape(uri.host), uri.port
    if uri.user && uri.password
      connection.login CGI::unescape(uri.user), CGI::unescape(uri.password)
    end
    yield connection
  ensure
    connection.close unless connection.closed?
  end
  
  module FTP
    class Server
      
      attr_reader :home_directory, :port

      def initialize(user_manager)
        @user_manager = user_manager
        @home_directory = Pathname(__FILE__).dirname.parent + "tmp" + "#{File::basename(@user_manager.class.name.underscore)}_test" 
        @port = Helper::next_port
      end
      
      def start
        FileUtils::rm_rf @home_directory if File.exists?(@home_directory)
        FileUtils::mkdir @home_directory
        FileUtils::mkdir @home_directory + "samples"
        File::open(@home_directory + "samples" + "test.dat", "w+") do |file|
          file << Faker::Lorem::paragraphs
        end

        @server = Harbor::FTP::Server.new
        @server.user_manager = @user_manager
        @server.port = @port
        Thread.new do
          @server.start
        end
        # I'm not really sure if this is necessary. I think it depends
        # on what you do after this returns. If you're going to go create
        # files to test with and such, it's probably unnecessary.
        # If you're going to try to immediately connect, then you might
        # run into timing issues without some sort of brief sleep.
        sleep 0.5 # Give the server time to start up.
        self
      end
      
      def stop
        @server.stop
        FileUtils::rm_rf @home_directory
        self
      end
    end
  end
end

module Net
  class FTP
    # Net::FTP#closed? doesn't handle the NullSocket case,
    # and throws an FTPConnectionError if you check it, so
    # this monkey-patch is here to resolve that.
    def closed?
      @sock == nil || @sock.is_a?(NullSocket) || @sock.closed?
    end
  end
end