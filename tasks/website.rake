desc 'Regenerates the contents of the website'
task :website do
  mkpath 'doc/output'
  Rake::Task[:spec_html].invoke
  Rake::Task[:rdoc].invoke
  Rake::Task[:rdoc_dev].invoke
  Rake::Task[:rcov].invoke
  WebsiteRakeHelpers.webgen
end

desc 'Removes generated documentation'
task :clobber do
  WebsiteRakeHelpers.clobber
end

module WebsiteRakeHelpers
  module_function

  # Remove generated documentation.
  def clobber
    rm_rf 'doc/output'
    rm_rf 'doc/tmp'
  end

  # Generates the website with webgen.
  def webgen
    Dir.chdir 'doc' do
      output = nil
      IO.popen('webgen 2>&1') do |io|
        output = io.read
      end
      raise "ERROR while running webgen: #{output}" if output =~ /ERROR/n || $? != 0
    end
  end
end
