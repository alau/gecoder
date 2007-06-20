module Gecode
  module IntEnumMethods
    # Specifies that a constraint must hold for the integer variable enum.
    def must
      IntVarEnumConstraintExpression.new(active_space, to_int_var_array)
    end
    alias_method :must_be, :must
    
    # Specifies that the negation of a constraint must hold for the integer 
    # variable.
    def must_not
      IntVarEnumConstraintExpression.new(active_space, to_int_var_array, 
        true)
    end
    alias_method :must_not_be, :must_not
  end
  
  # Describes a constraint expression that starts with an enumeration of int
  # variables followed by must or must_not.
  class IntVarEnumConstraintExpression
    # Constructs a new expression with the specified space and int var array 
    # with the (bound) variables as source. The expression can optionally be 
    # negated.
    def initialize(space, var_array, negate = false)
      @space = space
      @var_array = var_array
      @negate = negate
    end
  end
end

require 'gecoder/interface/constraints/int_enum/distinct'
