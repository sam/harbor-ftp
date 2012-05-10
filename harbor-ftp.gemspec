lib = (Pathname(__FILE__) + "lib").to_s
$:.unshift lib unless $:.include?(lib)

require 'harbor/ftp/version'

Gem::Specification.new do |s|
  s.name = "harbor-ftp"
  s.summary = s.description = "Harbor FTP Server"
  s.author = "Sam Smoot"
  s.homepage = "https://github.com/sam/harbor-ftp"
  s.email = "ssmoot@gmail.com"
  s.version = Harbor::FTP::VERSION
  s.platform = Gem::Platform::JRUBY
  s.require_path = "lib"
  s.files = %w(Rakefile harbor-ftp.gemspec README.textile) + Dir.glob("lib/**/*")

  s.add_dependency "logging"
  s.add_dependency "sequel"
  
  s.add_development_dependency "spawn"
  s.add_development_dependency "faker"
end