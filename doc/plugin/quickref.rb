class QuickRefTag < Tags::DefaultTag
  infos(:name => 'Tag/QuickrefTemplate',
        :author => 'Gecode/R',
        :summary => "Formats a template used in the documentation's quick reference.")
  
  param 'template', nil, 'The template of the constraint'
  set_mandatory 'template', true  

  register_tag 'quickrefTemplate'

  def process_tag( tag, chain )
    template = param('template')
    if template[-7..-1] == '&#8230;'
      return "<tt>#{template[0...-7]}</tt>&#8230;"
    else
      return "<tt>#{template}</tt>"
    end
  end
end
