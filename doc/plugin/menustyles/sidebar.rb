class SidbarMenuStyle < MenuStyles::DefaultMenuStyle
  infos( :name => 'MenuStyle/Sidebar',
         :author => 'Gecode/R',
         :summary => 'Builds the sidbar menu with links to the next level.'
         )

  register_handler 'sidebar'

  def internal_build_menu(src_node, menu_tree)
    if src_node.to_url.to_s =~ /index\.html/
      node = find_menu_node(menu_tree, src_node)
      return '' if node.parent.nil?

      menu = node.parent.inject('') do |out, child|
        next out if child.node_info[:node] == src_node
        _, link = menu_item_details(src_node, child.node_info[:node])
        out << "<li>#{link}</li>" 
      end
      "<h3>#{src_node.parent['title']}</h3><ul id=\"secondNav\">#{menu}</ul>"
    else
      ''
    end
  end
  
  private
  
  # Finds the node in the menu tree that corresponds to the specified node.
  def find_menu_node(menu_tree, node_to_find)
    match = node = menu_tree
    until match.nil?
      node = match
      match = node.find do |child| 
        node_to_find.in_subtree_of? child.node_info[:node]
      end
    end
    node
  end
end
