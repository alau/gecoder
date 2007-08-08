class SidbarMenuStyle < MenuStyles::DefaultMenuStyle
  infos( :name => 'MenuStyle/Sidebar',
         :author => 'Gecode/R',
         :summary => 'Builds the sidbar menu with links to the next level.'
         )

  register_handler 'sidebar'

  def internal_build_menu(src_node, menu_tree)
    if src_node.to_url.to_s =~ /index\.html/
      menu = src_node.parent.inject('<ul id="secondNav">') do |out, child|
        next out if child == src_node or 
          child.to_url.to_s =~ /\.template$|\.page$|\.xml$|\.css$|images/
        out << "<li>#{child.link_from(src_node)}</li>"
      end << '</ul>'
      "<h3>#{src_node.parent['title']}</h3>#{menu}"
    else
      ''
    end
  end
end
