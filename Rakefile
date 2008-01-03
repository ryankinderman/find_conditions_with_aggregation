require 'rake/testtask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the calculations plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end
