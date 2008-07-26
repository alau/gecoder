class GecodeRContentConverter < ContentConverters::DefaultContentConverter
  infos(:name => "ContentConverter/GecodeR", 
        :author => "Gecode/R", 
        :summary => "Performs the content converting used by Gecode/R.") 
        
  register_handler 'gecoder'
  
  def call(content)
    # Call the other content converters in the right order.
    content = @plugin_manager['ContentConverter/AddHeaderIds'].call(content)
    @plugin_manager['ContentConverter/Rspec'].call(content)
  end
end
