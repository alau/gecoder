module Gecode
  module SetEnumMethods
    include Gecode::Constraints::LeftHandSideMethods
    
    private
    
    # Produces an expression for the lhs module.
    def expression(params)
      params.update(:lhs => self)
      Constraints::SetEnum::Expression.new(@model, params)
    end
  end
  
  # A module containing constraints that have enumerations of set variables as 
  # left hand side.
  module Constraints::SetEnum
    # Expressions with set enums as left hand sides.
    class Expression < Gecode::Constraints::Expression
      # Raises TypeError unless the left hand side is a set enum.
      def initialize(model, params)
        super
        
        unless params[:lhs].respond_to? :to_set_var_array
          raise TypeError, 'Must have set enum as left hand side.'
        end
      end
    end
  end
end

require 'gecoder/interface/constraints/set_enum/channel'
require 'gecoder/interface/constraints/set_enum/distinct'
