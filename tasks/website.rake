desc 'Regenerates the contents of the website'
task :website do
  Rake::Task[:clobber].invoke
  mkdir 'doc/output'
  begin
    Rake::Task[:spec_html].invoke
  rescue
    # The task will fail unless all specs pass, we want it to continue.
  end
  Rake::Task[:rdoc].invoke
  begin
    Rake::Task[:rcov].invoke
  rescue
    # The task will fail unless all specs pass, we want it to continue.
  end
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