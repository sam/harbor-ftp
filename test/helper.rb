require "rubygems"
require "bundler/setup" unless Object::const_defined?("Bundler")

require "spawn"
require "faker"
require "sequel"

require "minitest/autorun"
require "minitest/pride"
require "minitest/wscolor"

$:.unshift (Pathname(__FILE__).dirname.parent + "lib").to_s
require "harbor/ftp"

org.apache.log4j.BasicConfigurator.configure

require "sequel"
DB = Sequel.connect("jdbc:h2:mem:")

Sequel.extension :migration
Sequel::Migrator.run(DB, Pathname(__FILE__).dirname.parent + "db/migrations")

require_relative "data/user"

require "thread"
require "net/ftp"
require "uri"
require "cgi"

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