class SectionsMenuStyle < MenuStyles::DefaultMenuStyle
  infos( :name => 'MenuStyle/Sections',
         :author => 'Gecode/R',
         :summary => 'Builds a menu with links to the headers present on the page.'
         )

  register_handler 'sections'

  def internal_build_menu(src_node, menu_tree)
    sections = src_node.node_info[:pagesections]
    return section_menu(sections, 1)
  end
  
  private
  
  # Builds a menu out of the page's sections.
  def section_menu(sections, level)
    return '' if sections.empty? || level > 2

    sections.inject('<ul class="section-links">') do |menu, child|
      menu << "<li><a href=\"##{child.id}\">#{child.title}</a>"
      unless child.subsections.empty?
        menu << section_menu(child.subsections, level + 1)
      end
      menu << "</li>"
    end << "</ul>"
  end
end
