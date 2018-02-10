require 'bundler'
Bundler.setup

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "fstui/version"

desc "Builds the gem"
task :gem => :build
task :build do
  system "gem1.9 build fstui.gemspec"
  Dir.mkdir("pkg") unless Dir.exists?("pkg")
  system "mv fstui-#{FSTui::VERSION}.gem pkg/"
end

task :install => :build do
  system "sudo gem1.9 install pkg/fstui-#{FSTui::VERSION}.gem"
end

desc "Release the gem - Gemcutter"
task :release => :build do
  system "git tag -a v#{FSTui::VERSION} -m 'Tagging #{FSTui::VERSION}'"
  system "git push --tags"
  system "gem push pkg/bmix-#{FSTui::VERSION}.gem"
end

task :default => [:spec]
