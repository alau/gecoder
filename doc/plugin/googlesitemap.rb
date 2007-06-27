# A webgen plugin by Vincent Fourmond to write nice google site maps
# according to the specs found there:
# 
# https://www.google.com/webmasters/sitemaps/docs/en/protocol.html
#
# This file is copyright 2007 by Vincent Fourmond, and can be used and
# redistributed under the same terms as webgen itself.
#
# Enjoy !

require 'yaml'

class GoogleSiteMapHandler < FileHandlers::DefaultHandler
  
  infos( :name => 'File/GoogleSiteMapHandler',
         :author => 'Vincent Fourmond <vincent.fourmond@9online.fr>',
         :summary => "Creates a google site map for your nice website"
         )
  
  param 'baseUrl', "http://biniou.com", 'The base url of the website ' +
    'which match the files that should get copied by this handler.'

  param 'defaultFrequency', "monthly", "The default change frequency for pages"
  param 'defaultPriority', "0.5", "The default priority of the pages"
  param 'gzip', false, "Whether the file should be gzipped in the end. " + 
    "You need the gzip program for this to work"
  
  
  def initialize( plugin_manager )
    super
    register_path_pattern( "**/*.sitemap" ) # YAML files
    @nodes = 0                  # The number of nodes dealt with
  end

  # Writes a node to the XML output
  def write_xml_node(out, loc, date, 
                     freq = param('defaultFrequency'),
                     priority = param('defaultPriority'))
    out.puts "<url>\n" + 
      "  <loc>#{loc}</loc>\n" +
      "  <lastmod>#{date}</lastmod>\n" + 
      "  <changefreq>#{freq}</changefreq>\n" + 
      "  <priority>#{priority}</priority>\n" + 
      "</url>\n"
    @nodes += 1
  end

  def create_node( path, parent, meta_info )
    # Transform
    name = File.basename( path ).gsub(/sitemap$/,"xml")
    node = Node.new( parent, name )
    node.node_info[:processor] = self
    begin
      node.node_info[:sitemap_info] = YAML::load(File.read(path))
    rescue
      node.node_info[:sitemap_info] = {}
    end
    node
  end
  
  # Returns a hash containing decent information about
  # the Sitemap node, ie its base url and other informations.
  # All the plugin parameters can be overridden here.
  def map_info(node)
    h = {}
    for k,v in self.class.config.params
      h[k] = param(k)
    end
    h.update(node.node_info[:sitemap_info])
    return h
  end

  # Handles static trees.
  # An example:
  # staticTrees:
  #   biniou:
  #     - bidule//**/*.html
  #     - ../../blog//bidule/**/*.htm
  # This will include the files bidule/**/*.html into
  # biniou/**/*.html  and ../../blog/bidule/**/*.htm
  # as biniou/bidule/**/*.htm
  #
  # This way, you can have fun rewriting the filepaths
  #
  def handle_static_trees(f, map_info)
    for target, globs in map_info['staticTrees']
      if target == '.'
        # Special case, the static file is in the root.
        target = ''
      else
        # We add a trailing / to the target:
        target = target.gsub(/(.)\/?$/,'\1/')
      end
      for file in globs.map {|g| Dir.glob(g)}.flatten
        date = File.mtime(file).strftime("%Y-%m-%d")
        dest = file.gsub(/^(.*?\/\/)?/, target)
        write_xml_node(f, "#{map_info['baseUrl']}/#{dest}", 
                       date, map_info['defaultFrequency'],
                       map_info['staticPriority'])
      end
    end
  end
  
  # Copy the file to the destination directory if it has been modified.
  def write_node( node )
    f = File.open(node.full_path, "w")
    f.puts '<?xml version="1.0" encoding="UTF-8"?>'
    f.puts '<urlset xmlns="http://www.google.com/schemas/sitemap/0.84">'

    # The nodes we're interested in:
    nodes = find_all_nodes(node.parent)
    map_info = map_info(node)
    for n in nodes
      if n.class.to_s =~ /Page/
        target = n.absolute_path
        if target =~ /.html$/
          frequency = n["gFrequency"] || map_info['defaultFrequency']
          priority = n["gPriority"] || map_info['defaultPriority']
          date = File.mtime(n.node_info[:src]).strftime("%Y-%m-%d")
          write_xml_node(f,"#{map_info['baseUrl']}#{target}",
                         date, frequency, priority)
        end
      end
    end
    handle_static_trees(f, map_info)
    f.puts '</urlset>'
    f.close
    dest = node.absolute_path
    if map_info['gzip']
      system "rm #{node.full_path}.gz"
      system "gzip #{node.full_path}"
      dest += ".gz"
    end
    log(:info){"Wrote #{@nodes} to sitemap #{dest}"}
  end

  # Finds all nodes derived from this one, and return them as an array.
  def find_all_nodes(parent)
    a = []
    for n in parent
      a << n
      if n.class.to_s =~ /DirNode/
        a += find_all_nodes(n)
      end
    end
    return a
  end
  
end

