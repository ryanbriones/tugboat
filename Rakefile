require 'rubygems'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name = 'tugboat'
  s.version = '0.0.1'
  s.summary = 'Pulling your applications into port for deployment'
  s.files = FileList['[A-Z]*', 'bin/*', 'lib/**/*']
  s.has_rdoc = false
  s.bindir = 'bin'
  s.executables = ['tug']
  s.default_executable = 'tug'
  s.author = 'Ryan Carmelo Briones'
  s.email = 'ryan.briones@brionesandco.com'
  s.homepage = 'http://brionesandco.com/ryanbriones'
end

package_task = Rake::GemPackageTask.new(spec) {}

task :build_gemspec do
  File.open("#{spec.name}.gemspec", "w") do |f|
    f.write spec.to_ruby
  end
end

task :default => [:build_gemspec, :gem]
