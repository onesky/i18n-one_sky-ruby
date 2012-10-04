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


######
# Uken Gem uploading
###
require 'yaml'
require 'stickler'
require 'stickler/client'

namespace :gem do
  UKEN_GEM_SERVER = "http://gems.uken.com"
  def gemspec_file; Dir["*.gemspec"].first; end
  def gemspec; eval File.read(gemspec_file); end
  def name; gemspec.name; end
  def version; gemspec.version; end
  def version_tag; "v#{version}"; end
  def gemfile; "pkg/#{name}-#{version}.gem"; end
  def escape n; "\e[#{n}m" if $stdout.tty?; end
  def ohai msg; puts "#{escape "1;34"}==>#{escape "1;39"} #{msg}#{escape 0}"; end

  desc "Build #{name}-#{version}.gem into the pkg directory"
  task :build do
    system <<-COMMAND
      mkdir -p pkg
      gem build #{gemspec_file} -q
      mv *.gem pkg
    COMMAND
  end

  desc "Create tag #{version_tag} and build and push #{name}-#{version}.gem to Uken gemserver"
  task :push do
    ::Stickler::Client::Push.new([ gemfile, "--server", UKEN_GEM_SERVER ]).run
    system "git tag #{version_tag}"
    ohai "Don't forget to 'git push --tags'"
  end
end

desc 'Builds and pushes the gem'
task :gem => ['gem:build', 'gem:push']
