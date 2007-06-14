require 'spec/rake/spectask'

Spec::Rake::SpecTask.new('specs') do |t|
  t.spec_opts = ["--format", "specdoc"]
  t.libs = ['lib']
  t.spec_files = FileList['specs/**/*.rb']
end
