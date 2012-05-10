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

class Object
  def self.public!(method)
    self.public method
  end
end

require "sequel"
DB = Sequel.connect("jdbc:h2:mem:")

Sequel.extension :migration
Sequel::Migrator.run(DB, Pathname(__FILE__).dirname.parent + "db/migrations")

require "data/user"