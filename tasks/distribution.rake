require 'lib/gecoder/version'

PKG_NAME = 'gecoder'
PKG_VERSION = GecodeR::VERSION
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"

desc 'Generate RDoc'
rd = Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = "#{File.dirname(__FILE__)}/../doc/output/rdoc"
  rdoc.options << '--title' << 'Gecode/R' << '--line-numbers' << '--inline-source' << '--main' << 'README'
  rdoc.rdoc_files.include('README', 'lib/**/*.rb')
end

spec = Gem::Specification.new do |s|
  s.name = PKG_NAME
  s.version = GecodeR::VERSION
  s.summary = 'Ruby interface to Gecode, an environment for constraint programming.'

  s.files = FileList[
    '[A-Z]*',
    'lib/**/*.rb', 
    'examples/**/*',
    'src/**/*',
    'vendor/**/*',
    'tasks/**/*',
    'specs/**/*',
    'ext/*'
  ].to_a
  s.require_path = 'lib'
  s.extensions << 'ext/extconf.rb'

  s.has_rdoc = true
  s.rdoc_options = rd.options
  s.extra_rdoc_files = rd.rdoc_files

  s.autorequire = 'gecoder'
  s.author = ["Gecode/R Development Team"]
  s.email = "gecoder-devel@rubyforge.org"
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
