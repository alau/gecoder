desc 'Generate RDoc'
rd = Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = "#{File.dirname(__FILE__)}/../doc/output/rdoc"
  rdoc.options << '--title' << 'Gecode/R' << '--line-numbers' << '--inline-source' << '--main' << 'README'
  rdoc.rdoc_files.include('README', 'lib/**/*.rb')
end

spec = Gem::Specification.new do |s|
  s.name = 'gecoder'
  s.version = '0.2'
  s.summary = 'Ruby interface to Gecode, an environment for constraint programming.'

  s.files = FileList[
    '[A-Z]*',
    'lib/**/*.rb', 
    'examples/**/*',
    'bin/**/*',
    'src/**/*',
    'vendor/**/*',
    'ext/*'
  ].to_a
  s.require_path = 'lib'
  s.extensions << 'ext/extconf.rb'

  s.has_rdoc = true
  s.rdoc_options = rd.options
  s.extra_rdoc_files = rd.rdoc_files

  s.autorequire = 'gecoder'
  s.author = ["Gecode/R Development Team"]
  #s.email = "gecoder-devel@rubyforge.org"
  s.homepage = "http://gecoder.rubyforge.org"
  s.rubyforge_project = "gecoder"
end

desc 'Generate Gem'
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end