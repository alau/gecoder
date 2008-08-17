require 'cgi'

class ImportRDocTag < Tags::DefaultTag
  infos(:name => 'CustomTag/ImportRDoc',
        :author => 'Gecode/R',
        :summary => 'Imports and converts method documentation from RDoc.')
  
  param 'file', nil, 'The file to import from given as a path from /lib/gecoder/interface.'
  param 'method', nil, 'The name of the method.'
  set_mandatory 'file', true  
  set_mandatory 'method', true  

  register_tag 'importRDoc'

  def process_tag(tag, chain)
    rdoc_buffer = []
    method = CGI::unescapeHTML(param('method'))
    call_sequence = nil

    # Fetch the block of comments (respecting --).
    file_path = "../lib/gecoder/interface/#{param('file')}"
    end_of_comment = false
    File.new(file_path, 'r').each_line do |line|
      if line.include? method
        call_sequence = line
        break
      end
      line.strip!
      if !line.empty? and line[0].chr == '#'
        if line[0..2] == '#--'
          end_of_comment = true
        end
        unless end_of_comment
          rdoc_buffer << line[2..-1]
        end
      else
        rdoc_buffer = []
        end_of_comment = false
      end
    end
    raise "Could not find #{method}." if call_sequence.nil?

    # Process the RDoc a bit.

    # The textile @ are more reliable than the RDoc + .
    rdoc_buffer.map! do |line|
      unless line.nil? or line.strip.empty? or line.strip[0].chr == '#'
        line.gsub(/\+(.+?)\+/, '@\1@')
      else
        line
      end
    end
    output = rdoc_buffer.join("\n")

    # Use h5 rather than h4.
    output.gsub!(/^==== /, '===== ')

    # Use <ruby>...</ruby> for code.
    output = @plugin_manager['ContentConverter/RDoc'].call(output)
    output.gsub!('<pre>', '<ruby>')
    output.gsub!('</pre>', '</ruby>')
    output = CGI::unescapeHTML(output)
    output.gsub!(/^  /, '')

    # Add the call sequence.
    call_sequence.gsub!(/(^| )def /, '')
    call_sequence.strip!
    call_sequence << '()' unless call_sequence[-1].chr == ')'
    "<code>#{call_sequence}</code>" +
      @plugin_manager['ContentConverter/GecodeR'].call(output)
  end
end
