require "rubygems"
require "pathname"
require "rake"
require "rake/rdoctask"
require "rake/testtask"

def gemspec
  @gemspec ||= begin
    file = File.expand_path('../harbor-ftp.gemspec', __FILE__)
    eval(File.read(file), binding, file)
  end
end

# Tests
task :default => [ :test ]

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_spec.rb"]
  t.verbose = true
end

task :rdoc do
  sh <<-EOS.strip
rdoc -T harbor-ftp#{" --op " + ENV["OUTPUT_DIRECTORY"] if ENV["OUTPUT_DIRECTORY"]} --line-numbers --main README --title "Harbor FTP Server Documentation" lib/harbor README.textile
  EOS
end

require "rake/gempackagetask"
Rake::GemPackageTask.new(gemspec) do |package|
  package.gem_spec = gemspec
end

desc "Install Harbor as a gem"
task :install => [:repackage] do
  sh %{gem install pkg/#{gemspec.full_name}}
end