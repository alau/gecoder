require File.dirname(__FILE__) + "/rspec_content"

class AddHeaderIdsContentConverter < ContentConverters::DefaultContentConverter
  infos(:name => "ContentConverter/AddHeaderIds", 
        :author => "Gecode/R", 
        :summary => "Adds ids to headers so that they are included in the section menu.") 
        
  register_handler 'add_header_ids'
  
  def call(content)
    # Add ids to all headers at level 2 or lower.
    characters = ('a'..'z').to_a
    content.map do |line|
      match = /h(\d)\. (.+)$/.match line
      next line if match.nil? or match[1].to_i < 2
      id = match[2].downcase.tr("^#{characters.join}", '_')
      line.sub(/h#{match[1]}\./, "h#{match[1]}(##{id}).")
    end.join
  end
end
