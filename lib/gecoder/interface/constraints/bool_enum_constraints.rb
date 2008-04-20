module Gecode
  module BoolEnumMethods
    include Gecode::Constraints::LeftHandSideMethods
    
    private
    
    # Produces an expression for the lhs module.
    def expression(params)
      params.update(:lhs => self)
      Constraints::BoolEnum::Expression.new(@model, params)
    end
  end
  
  # A module containing constraints that have enumerations of boolean variables 
  # as left hand side.
  module Constraints::BoolEnum
    # Expressions with bool enums as left hand sides.
    class Expression < Gecode::Constraints::Expression #:nodoc:
      # Raises TypeError unless the left hand side is a bool enum.
      def initialize(model, params)
        super
        
        unless params[:lhs].respond_to? :to_bool_var_array
          raise TypeError, 'Must have bool enum as left hand side.'
        end
      end
    end
  end
end

require 'gecoder/interface/constraints/bool_enum/relation'
require 'gecoder/interface/constraints/bool_enum/extensional'
