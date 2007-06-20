module Gecode
  class FreeIntVar
    # Specifies that a constraint must hold for the integer variable.
    def must
      Gecode::IntVarConstraintExpression.new(active_space, self.bind)
    end
    
    # Specifies that the negation of a constraint must hold for the integer 
    # variable.
    def must_not
      Gecode::IntVarConstraintExpression.new(active_space, self.bind, true)
    end
  end
  
  # A module containing constraints that have int variables as left hand side
  # (but not enumerations).
  module Constraints::Int
  end
end

require 'gecoder/interface/constraints/int/linear'
require 'gecoder/interface/constraints/int/relation'
