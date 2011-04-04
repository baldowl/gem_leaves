require 'rake/clean'
require 'rake/rdoctask'
require 'jeweler'

version = File.exists?('VERSION') ? File.read('VERSION').strip : ''

Rake::RDocTask.new :doc do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = "GemLeaves #{version}"
  rdoc.rdoc_files.include('README.rdoc', 'LICENSE.rdoc', 'History.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Jeweler::Tasks.new do |gem|
  gem.name = 'gem_leaves'
  gem.summary = 'A dumb tool to list removable gems'
  gem.description = 'A dumb tool to list removable gems'
  gem.license = 'MIT'
  gem.authors = 'Gufo Pelato'
  gem.email = 'gufo.pelato@gmail.com'
  gem.homepage = 'http://github.com/baldowl/gem_leaves'
  gem.rubyforge_project = 'gemleaves'
  gem.add_development_dependency 'cucumber', '>= 0.1.13'
  gem.add_development_dependency 'rspec'
  gem.rdoc_options << '--line-numbers' << '--inline-source' << '--title' <<
    "GemLeaves #{version}" << '--main' << 'README.rdoc'
  gem.test_files.clear
end

Jeweler::GemcutterTasks.new
