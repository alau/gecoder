module Gecode
  class FreeBoolVar
    include Gecode::Constraints::LeftHandSideMethods
    
    private
    
    # Produces an expression for the lhs module.
    def expression(params)
      params.update(:lhs => self)
      Constraints::Bool::Expression.new(@model, params)
    end
  end
  
  # A module containing constraints that have int variables as left hand side
  # (but not enumerations).
  module Constraints::Bool
    # Describes a boolean expression.
    class Expression < Gecode::Constraints::Expression
    end
  end
end

require 'gecoder/interface/constraints/bool/boolean'
