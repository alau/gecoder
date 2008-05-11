module Gecode::Constraints::Bool
  class Expression
    # Constrains the boolean variable to be equal to the specified integer 
    # variable.
    provide_commutivity(:==){ |rhs, _| rhs.kind_of?(Gecode::FreeIntVar) }
    alias_comparison_methods
  end
end
