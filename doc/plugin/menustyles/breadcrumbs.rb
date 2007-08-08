# Based on the breadcrumb plugin for RSpec.rubyforge.org's menu by Aslak 
# Hellesoy.
class BreadcrumbsMenuStyle < MenuStyles::DefaultMenuStyle
  infos( :name => 'MenuStyle/Breadcrumbs',
         :author => '',
         :summary => 'Builds a bradcrumb trail menu.')
    
  register_handler 'breadcrumbs'
    
  def internal_build_menu(src_node, menu_tree)
    return '' if src_node.parent == src_node
    crumbs = trail(src_node, menu_tree.node_info[:node]).inject([]) do |trail, node|
      link = node.link_from(src_node)
      trail << link
      if link =~ /<span>/
        break trail
      else
        next trail
      end
    end 
    '<div id="breadcrumbs">' << crumbs.join(' > ') << '</div>'
  end
    
  def trail(node, root_node)
    nodes = []
    until node.parent.nil?
      nodes << node
      node = node.parent 
    end
    nodes << root_node
    nodes.reverse
  end
end