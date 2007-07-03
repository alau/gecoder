require 'lib/gecoder/version'

desc "Tag the release in svn"
task :tag do
  from = `svn info`.match(/Repository Root: (.*)/n)[1] + '/trunk'
  to = from.gsub(/trunk/, "tags/#{GecodeR::VERSION}")

  puts "Creating tag in SVN"
  tag_cmd = "svn cp #{from} #{to} -m \"Tag release Gecode/R #{GecodeR::VERSION}\""
  `#{tag_cmd}` ; raise "ERROR: #{tag_cmd}" unless $? == 0
end
