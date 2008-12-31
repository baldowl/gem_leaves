require 'rubygems'
require 'echoe'
require './lib/gem_leaves.rb'

Echoe.new('gem_leaves', GemLeaves::VERSION) do |p|
  p.author = 'Gufo Pelato'
  p.summary = 'A dumb tool to list removable gems.'
  p.need_tar_gz = false
  p.project = nil
  p.gemspec_format = :yaml
  p.retain_gemspec = true
  p.rdoc_pattern = /^README|^LICENSE/
  p.url = 'http://github.com/baldowl/gem_leaves'
end
