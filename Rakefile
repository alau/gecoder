require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

require 'tasks/all_tasks'
task :default => [:verify_rcov, :example_specs]

desc 'Performs the tasks necessary when releasing'
task :release => [:clobber, :verify_rcov, :example_specs, :publish_website, 
  :publish_packages, :tag]

desc 'Runs all the tests'
task :test => :specs