require 'harbor/ftp/version'

Gem::Specification.new do |s|
  s.name = "harbor-ftp"
  s.summary = s.description = "Harbor FTP Server"
  s.author = "Sam Smoot"
  s.homepage = "https://github.com/sam/harbor-ftp"
  s.email = "ssmoot@gmail.com"
  s.version = Harbor::FTP::VERSION
  s.platform = "java"
  s.require_path = "lib"
  s.files = %w(Rakefile harbor-ftp.gemspec README.textile) + Dir.glob("lib/**/*") + Dir.glob("jars/*")

  s.add_dependency "logging"
  s.add_dependency "sequel"
  
  s.add_development_dependency "spawn"
  s.add_development_dependency "faker"
end