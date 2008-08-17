require 'cgi'

class RDocTag < Tags::DefaultTag
  infos(:name => 'CustomTag/RDoc',
        :author => 'Gecode/R',
        :summary => 'Links to RDoc documentation given a class name and optionally a method name.')
  
  param 'target', nil, 'The name of the class to link to. May contain an instance method name, e.g. Class#method .'
  set_mandatory 'target', true  

  register_tag 'RDoc'

  def process_tag(tag, chain)
    target_param = CGI::unescapeHTML(param('target'))

    target = target_param.split('::').last
    rdoc_class = target.split('#').first
    method = nil
    unless target.split('#').size == 1
      method = target.split('#').last
    end

    rdoc_file = Dir["output/rdoc/**/#{rdoc_class}.html"]
    unless rdoc_file.size == 1
      raise "Could not find exactly one #{target_param}." 
    end
    rdoc_file = rdoc_file.first

    root_href = chain.last.route_to(Node.root(chain.last))
    rdoc_href = rdoc_file.split('/')[1..-1].join('/')

    ref = ''
    unless method.nil?
      File.new(rdoc_file, 'r').each_line do |line|
        if match = line.match(%r{<a href="(#.+?)">#{Regexp.escape(method)}</a>})
          ref = match[1]
          break
        end
      end
    end

    return "<a href=\"#{root_href}#{rdoc_href}#{ref}\"><code>#{target_param}</code></a>"
  end
end
