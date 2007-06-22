module Gecode
  module IntEnumMethods
    # Specifies that a constraint must hold for the integer variable enum.
    def must
      Constraints::IntEnum::Expression.new(active_space, self)
    end
    alias_method :must_be, :must
    
    # Specifies that the negation of a constraint must hold for the integer 
    # variable.
    def must_not
      Constraints::IntEnum::Expression.new(active_space, self, true)
    end
    alias_method :must_not_be, :must_not
  end
  
  # A module containing constraints that have enumerations of integer 
  # variables as left hand side.
  module Constraints::IntEnum
    # Describes a constraint expression that starts with an enumeration of int
    # variables followed by must or must_not.
    class Expression
      # Constructs a new expression with the specified space and int var array 
      # with the (free) variables as source. The expression can optionally be 
      # negated.
      def initialize(space, var_array, negate = false)
        @space = space
        @var_array = var_array
        @negate = negate
      end
    end
  end
end

require 'gecoder/interface/constraints/int_enum/distinct'
