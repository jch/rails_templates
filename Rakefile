require 'rake'
require 'rake/testtask'

desc "Rm backup files"
task :clean do
  `find . -name '*~' | xargs rm -f`
end

Rake::TestTask.new do |t|
  t.libs << [".", "test"]
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

task :default => :test
