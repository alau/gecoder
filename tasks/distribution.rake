require 'lib/gecoder/version'

PROJECT_NAME = PKG_NAME = 'gecoder'
PKG_NAME_WITH_GECODE = 'gecoder-with-gecode'
PKG_VERSION = GecodeR::VERSION
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"
PKG_FILE_NAME_WITH_GECODE = "#{PKG_NAME_WITH_GECODE}-#{PKG_VERSION}"
# The location where the precompiled DLL should be placed.
DLL_LOCATION = 'lib/gecode.dll'
EXT_DIR = 'ext'

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
    'vendor/rust/**/*',
    'tasks/**/*',
    'specs/**/*',
    'ext/*.cpp',
    'ext/*.h',
    'ext/extconf.rb'
  ].to_a
  s.require_path = 'lib'
  s.extensions << 'ext/extconf.rb'
  s.requirements << 'Gecode 2.1.1'

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

# Create a clone of the gem spec with the precompiled binaries for Windows.
spec_windows_binary_with_gecode = spec.dup
spec_windows_binary_with_gecode.name = PKG_NAME_WITH_GECODE
spec_windows_binary_with_gecode.extensions = []
spec_windows_binary_with_gecode.requirements = []
# Add the precompiled Gecode DLLs and precompiled bindings.
spec_windows_binary_with_gecode.files = spec.files.dup -
  FileList['ext/**/*'].to_a + 
  FileList['vendor/gecode/win32/lib/*'].to_a << 'lib/gecode.dll'
spec_windows_binary_with_gecode.platform = Gem::Platform::WIN32

# Create a clone of the gem spec that includes Gecode.
spec_with_gecode = spec.dup
spec_with_gecode.name = PKG_NAME_WITH_GECODE
spec_with_gecode.extensions = 
  spec_with_gecode.extensions.dup.unshift 'ext/gecode-2.1.1/configure'
spec_with_gecode.requirements = []
spec_with_gecode.files = spec.files.dup + FileList['ext/gecode-*/**/*'].to_a 

desc 'Generate Gecode/R Gem'
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc 'Generate Gecode/R + Gecode Gem'
Rake::GemPackageTask.new(spec_with_gecode) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc 'Generate Gecode/R + Gecode Gem (windows binary)'
Rake::GemPackageTask.new(spec_windows_binary_with_gecode) do |pkg|
end

desc 'Precompiles the Gecode/R bindings for Windows platforms'
file 'lib/gecode.dll' do
  cd 'ext' do
    sh 'ruby -Iwin32 extconf-win32.rb'
    sh 'make'
    mv 'gecode.so', "../#{DLL_LOCATION}"
  end
end

desc 'Removes generated distribution files'
task :clobber do
  rm DLL_LOCATION if File.exists? DLL_LOCATION
  FileList[
    "#{EXT_DIR}/*.o",
    "#{EXT_DIR}/gecode.{cc,hh}",
    "#{EXT_DIR}/Makefile",
    "#{EXT_DIR}/mkmf.log"
  ].to_a.each{ |file| rm file if File.exists? file }
end

desc 'Publish packages on RubyForge'
task :publish_packages => [:publish_gecoder_packages, 
  :publish_gecoder_with_gecode_packages]

desc 'Publish Gecode/R packages on RubyForge'
task :publish_gecoder_packages => [:verify_user, :package] do
  release_files = FileList[
    "pkg/#{PKG_FILE_NAME}.gem",
    "pkg/#{PKG_FILE_NAME}.tgz",
    "pkg/#{PKG_FILE_NAME}.zip"
  ]
  require 'meta_project'
  require 'rake/contrib/xforge'

  Rake::XForge::Release.new(MetaProject::Project::XForge::RubyForge.new(PROJECT_NAME)) do |xf|
    xf.user_name = ENV['RUBYFORGE_USER']
    xf.files = release_files.to_a
    xf.release_name = "Gecode/R #{PKG_VERSION}"
    xf.package_name = PKG_NAME
  end
end

desc 'Publish Gecode/R with Gecode packages on RubyForge'
task :publish_gecoder_with_gecode_packages => [:verify_user, :package] do
  release_files = FileList[
    "pkg/#{PKG_FILE_NAME_WITH_GECODE}*.gem",
    "pkg/#{PKG_FILE_NAME_WITH_GECODE}*.tgz",
    "pkg/#{PKG_FILE_NAME_WITH_GECODE}*.zip"
  ]
  
  require 'meta_project'
  require 'rake/contrib/xforge'

  Rake::XForge::Release.new(MetaProject::Project::XForge::RubyForge.new(PROJECT_NAME)) do |xf|
    xf.user_name = ENV['RUBYFORGE_USER']
    xf.files = release_files.to_a
    xf.release_name = "Gecode/R with Gecode #{PKG_VERSION}"
    xf.package_name = PKG_NAME_WITH_GECODE
  end
end
