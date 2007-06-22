module Gecode
  class FreeIntVar
    include Gecode::Constraints::LeftHandSideMethods
    
    private
    
    # Produces an expression for the lhs module.
    def expression(params)
      params.update(:lhs => self, :space => active_space)
      Constraints::Int::Expression.new(params)
    end
  end
  
  # A module containing constraints that have int variables as left hand side
  # (but not enumerations).
  module Constraints::Int
    class Expression < Gecode::Constraints::Expression
    end
  end
end

require 'gecoder/interface/constraints/int/linear'
