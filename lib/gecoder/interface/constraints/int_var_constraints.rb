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
end