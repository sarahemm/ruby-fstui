# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'fstui/version'

Gem::Specification.new do |s|
  s.name = "fstui"
  s.version = FSTui::VERSION

  s.description = "Full screen text UI library"
  s.homepage = "http://github.com/sarahemm/ruby-fstui"
  s.summary = "Full Screen TUI library"
  s.licenses = "MIT"
  s.authors = ["sarahemm"]
  s.email = "github@sen.cx"
  
  s.files = Dir.glob("{lib,spec}/**/*") + %w(README.md Rakefile)
  s.require_path = "lib"

  s.rubygems_version = "1.3.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
end
