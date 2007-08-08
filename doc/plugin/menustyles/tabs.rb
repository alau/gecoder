class TabMenuStyle < MenuStyles::DefaultMenuStyle
  infos( :name => 'MenuStyle/Tabs',
         :author => 'Gecode/R',
         :summary => "Builds a menu of tabs describing the top level navigation."
         )

  register_handler 'tabs'

  def internal_build_menu(src_node, menu_tree)
    menu_tree.inject('<div id="tabs"><ul>') do |out, child|
      node = child.node_info[:node]
      style, link = menu_item_details(src_node, node)
      if node == src_node || (node.is_directory? && src_node.in_subtree_of?(node))
        out << "<li class=\"selected\">#{link}</li>"
      else
        out << "<li>#{link}</li>"
      end
    end << '</ul></div>'
  end
end
