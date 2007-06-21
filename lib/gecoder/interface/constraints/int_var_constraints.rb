module Gecode
  class FreeIntVar
    # Specifies that a constraint must hold for the integer variable.
    def must
      Gecode::Constraints::Int::Expression.new(active_space, self)
    end
    
    # Specifies that the negation of a constraint must hold for the integer 
    # variable.
    def must_not
      Gecode::Constraints::Int::Expression.new(active_space, self, true)
    end
  end
  
  # A module containing constraints that have int variables as left hand side
  # (but not enumerations).
  module Constraints::Int
    # Describes a linear constraint expression that has int variables as left
    # hand side.
    class Expression
      # Constructs the expression with the specified left hand side. The 
      # expression can optionally be negated.
      def initialize(space, left_hand_side, negate = false)
        @space = space
        @lhs = left_hand_side
        @negate = negate
      end
    end
  end
end

require 'gecoder/interface/constraints/int/linear'
