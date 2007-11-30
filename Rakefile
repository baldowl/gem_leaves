require 'rubygems'
require 'hoe'
require './lib/gem_leaves.rb'

Hoe.new('GemLeaves', GemLeaves::VERSION) do |p|
  p.author = 'Gufo Pelato'
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.email = 'gufo.pelato@gmail.com'
  p.rubyforge_name = 'gem_leaves'
  p.summary = 'Dumb tool to list removable gems'
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[-1]
end
