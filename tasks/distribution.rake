require 'lib/gecoder/version'

PKG_NAME = 'gecoder'
PKG_VERSION = GecodeR::VERSION
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"

desc 'Generate RDoc'
rd = Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc/output/rdoc'
  rdoc.options << '--title' << 'Gecode/R' << '--line-numbers' << 
    '--inline-source' << '--accessor' << 'delegate' << '--main' << 'README'
  rdoc.rdoc_files.include('README', 'CHANGES', 'LGPL-LICENSE', 'lib/**/*.rb')
end

desc 'Generate RDoc, ignoring nodoc'
Rake::RDocTask.new(:rdoc_dev) do |rdoc|
  rdoc.rdoc_dir = 'doc/output/rdoc_dev'
  rdoc.options << '--title' << 'Gecode/R Developers RDoc' << '--line-numbers' << 
    '--inline-source' << '--accessor' << 'delegate'
    
  # Copy the rdoc and remove all #:nodoc: .
  TMP_DIR = 'doc/tmp/rdoc_dev'
  Dir['lib/**/*.rb'].each do |source_name|
    destination_name = source_name.sub('lib', TMP_DIR)
    File.makedirs File.dirname(destination_name)
    destination = File.open(destination_name, 'w')
    File.open(source_name) do |source|
      source.each{ |line| destination << line.gsub('#:nodoc:', '' ) }
    end
    destination.close
  end
  
  rdoc.rdoc_files.include("#{TMP_DIR}/**/*.rb")
end

spec = Gem::Specification.new do |s|
  s.name = PKG_NAME
  s.version = GecodeR::VERSION
  s.summary = 'Ruby interface to Gecode, an environment for constraint programming.'
  s.description = <<-end_description
    Gecode/R is a Ruby interface to the Gecode constraint programming library. 
    Gecode/R is intended for people with no previous experience of constraint 
    programming, aiming to be easy to pick up and use.
  end_description

  s.files = FileList[
    '[A-Z]*',
    'lib/**/*.rb', 
    'example/**/*',
    'src/**/*',
    'vendor/**/*',
    'tasks/**/*',
    'specs/**/*',
    'ext/*'
  ].to_a
  s.require_path = 'lib'
  s.extensions << 'ext/extconf.rb'
  s.requirements << 'Gecode 1.3.1'

  s.has_rdoc = true
  s.rdoc_options = rd.options
  s.extra_rdoc_files = rd.rdoc_files
  s.test_files = FileList['specs/**/*.rb']

  s.autorequire = 'gecoder'
  s.author = ["Gecode/R Development Team"]
  s.email = "gecoder-users@rubyforge.org"
  s.homepage = "http://gecoder.rubyforge.org"
  s.rubyforge_project = "gecoder"
end

desc 'Generate Gem'
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc "Publish packages on RubyForge"
task :publish_packages => [:verify_user, :package] do
  release_files = FileList[
    "pkg/#{PKG_FILE_NAME}.gem",
    "pkg/#{PKG_FILE_NAME}.tgz",
    "pkg/#{PKG_FILE_NAME}.zip"
  ]
  require 'meta_project'
  require 'rake/contrib/xforge'

  Rake::XForge::Release.new(MetaProject::Project::XForge::RubyForge.new(PKG_NAME)) do |xf|
    xf.user_name = ENV['RUBYFORGE_USER']
    xf.files = release_files.to_a
    xf.release_name = "Gecode/R #{PKG_VERSION}"
  end
end
