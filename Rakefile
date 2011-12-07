require 'bundler'
Bundler::GemHelper.install_tasks

# = RDoc 
require 'rdoc/task'

Rake::RDocTask.new do |t|
  t.rdoc_dir = 'rdoc'
  t.options << '--line-numbers' << '--inline-source' << '-A cattr_accessor=object'
  t.options << '--charset' << 'utf-8'
  t.rdoc_files.include('README.rdoc', 'MIT-LICENSE', 'CHANGELOG', 'CREDITS', 'lib/**/*.rb')
end

require 'rspec/core/rake_task'

desc 'Default: run specs.'
task :default => :spec

desc "Run all specs"
RSpec::Core::RakeTask.new() do |t|
end

desc "Run offline specs"
RSpec::Core::RakeTask.new("spec:offline") do |t|
  t.rspec_opts = %w{--tag ~live}
end

desc "Run live specs"
RSpec::Core::RakeTask.new("spec:live") do |t|
  t.rspec_opts = %w{--tag live}
end
