class SidbarMenuStyle < MenuStyles::DefaultMenuStyle
  infos( :name => 'MenuStyle/Sidebar',
         :author => 'Gecode/R',
         :summary => 'Builds the sidbar menu with links to the next level.'
         )

  register_handler 'sidebar'

  def internal_build_menu(src_node, menu_tree)
    page_menu = ''
    node = find_menu_node(menu_tree, src_node)
    unless node.parent.nil? or src_node.parent['title'].empty?
      menu = node.parent.inject('') do |out, child|
        _, link = menu_item_details(src_node, child.node_info[:node])
        has_children = child.inject{ true }
        link.sub!('>', 'class="parent">') if has_children
        out << "<li>#{link}</li>" 
      end
      page_menu = "<h3>#{src_node.parent['title']}</h3><ul id=\"secondNav\">#{menu}</ul>"
    end

    return page_menu 
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
