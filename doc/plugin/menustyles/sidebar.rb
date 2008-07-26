class SidbarMenuStyle < MenuStyles::DefaultMenuStyle
  infos( :name => 'MenuStyle/Sidebar',
         :author => 'Gecode/R',
         :summary => 'Builds the sidbar menu with links to the next level.'
         )

  register_handler 'sidebar'

  def internal_build_menu(src_node, menu_tree)
    page_menu = ''
    if src_node.to_url.to_s =~ /index\.html/
      node = find_menu_node(menu_tree, src_node)
      return '' if node.parent.nil?

      menu = node.parent.inject('') do |out, child|
        next out if child.node_info[:node] == src_node
        _, link = menu_item_details(src_node, child.node_info[:node])
        out << "<li>#{link}</li>" 
      end
      page_menu = "<h3>#{src_node.parent['title']}</h3><ul id=\"secondNav\">#{menu}</ul>"
    end

    section_menu = ''
    sections = src_node.node_info[:pagesections]
    unless sections.empty?
      section_menu = '<h3>Shortcuts</h3>' + section_menu(sections, 1)
    end

    return page_menu + section_menu
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

  # Builds a menu out of the page's sections.
  def section_menu(sections, level)
    return '' if sections.empty? || level > 2

    sections.inject('<ul class="section_links">') do |menu, child|
      menu << "<li><a href=\"##{child.id}\">#{child.title}</a>"
      unless child.subsections.empty?
        menu << section_menu(child.subsections, level + 1)
      end
      menu << "</li>"
    end << "</ul>"
  end
end
