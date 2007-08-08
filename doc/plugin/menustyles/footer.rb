class FooterMenuStyle < MenuStyles::DefaultMenuStyle
  infos( :name => 'MenuStyle/Footer',
         :author => 'Gecode/R',
         :summary => 'Builds a footer menu.'
         )

  register_handler 'footer'

  def internal_build_menu(src_node, menu_tree)
    menu_tree.inject(
        '<div id="footer"><ul><li><a href="#top">Top</a></li>') do |out, child|
      node = child.node_info[:node]
      style, link = menu_item_details(src_node, node)
      if node == src_node || (node.is_directory? && src_node.in_subtree_of?(node))
        out << "<li class=\"selected\">#{link}</li>"
      else
        out << "<li>#{link}</li>"
      end
    end << '<li><a class="sitemap" href="{relocatable: sitemap.page}">' <<
      'Sitemap</a></li></ul></div>'
  end
end
