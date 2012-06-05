require_relative "lib/harbor/ftp/version"

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
  
  s.add_development_dependency "rake"
  s.add_development_dependency "sequel", ">= 3.36.1"
  s.add_development_dependency "faker"
  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-wscolor"
  s.add_development_dependency "bcrypt-ruby"
  s.add_development_dependency "jdbc-postgres"
  s.add_development_dependency "jdbc-h2"
  s.add_development_dependency "rjack-logback"
  s.add_development_dependency "listen"
end