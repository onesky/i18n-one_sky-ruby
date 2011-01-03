require 'bundler'
Bundler::GemHelper.install_tasks

# = RDoc 
require 'rake/rdoctask'

Rake::RDocTask.new do |t|
  t.rdoc_dir = 'rdoc'
  t.options << '--line-numbers' << '--inline-source' << '-A cattr_accessor=object'
  t.options << '--charset' << 'utf-8'
  t.rdoc_files.include('README.rdoc', 'MIT-LICENSE', 'CHANGELOG', 'CREDITS', 'lib/**/*.rb')
end

