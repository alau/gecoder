require 'cgi'

class ExampleScript < Tags::DefaultTag
  infos(:name => 'CustomTag/ExampleScript',
        :author => 'Gecode/R',
        :summary => 'Imports an example script.')
  
  param 'file', nil, 'The example script to import from given as the name of the script.'
  set_mandatory 'file', true  

  register_tag 'exampleScript'

  def process_tag(tag, chain)
    file_path = "../example/#{param('file')}"
    contents = File.readlines(file_path, 'r').join
    # Strip the initial copyright header. Replace the local type of
    # require with a require of the gem.
    contents.gsub!(/.*example_helper'\n/m, '')
    contents = "require 'rubygems'#{$/}require 'gecoder'#{$/}" + contents
    @plugin_manager['Misc/SyntaxHighlighter'].highlight(contents, 'ruby')
  end
end
