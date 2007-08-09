class ExampleTag < Tags::DefaultTag
  infos(:name => 'CustomTag/Example',
        :author => 'Gecode/R',
        :summary => 'Produces a link to the example with the specified name')
  
  param 'name', nil, 'The name of the example.'
  param 'linkText', nil, 'The link text that should be used, defaults to example name.'
  set_mandatory 'name', true  

  register_tag 'example'

  def process_tag(tag, chain)
    name = param('name')
    "<a href=\"#{link(chain.last, name)}\">#{param('linkText') || name}</a>"
  end

  private

  def link(node, example_name)
    root_route = node.route_to(Node.root(node))
    rel_url = "examples/#{example_name}.html"
    root_route + rel_url
  end
end
