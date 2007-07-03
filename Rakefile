require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

require 'tasks/all_tasks'
task :default => [:verify_rcov]

desc 'Performs the tasks necessary when releasing'
task :release => [:publish_website, :package, :tag]
