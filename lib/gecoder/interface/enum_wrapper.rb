module Gecode
  class Model
    private
    
    # Wraps a custom enumerable so that constraints can be specified using it.
    # The argument is altered and returned. 
    def wrap_enum(enum)
      unless enum.kind_of? Enumerable
        raise TypeError, 'Only enumerables can be wrapped.'
      end
      
      class <<enum
        include Gecode::IntEnumConstraintMethods
        
        def initialize_copy(other)
          super
        
          # Copy all int variables.
          map! do |var|
            var.clone
          end
        end
      end
      model = self
      enum.instance_eval{ @model = model }
      return enum
    end
  end
  
  # A module containing the methods needed by enumerations containing int 
  # variables. Requires that it's included in an enumerable and that @model 
  # exists.
  module IntEnumConstraintMethods
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
    
    # Returns an int variable array with all the bound variables.
    def to_int_var_array
      elements = to_a
      arr = Gecode::Raw::IntVarArray.new(active_space, elements.size)
      elements.each_with_index{ |var, index| arr[index] = var.bind }
      return arr
    end
    
    # Sets a new model for the variable array.
    def model=(new_model)
      each do |var|
        var.model = new_model
      end
      @model = new_model
    end
    
    # Gets the current space of the model the array is connected to.
    def active_space
      @model.active_space
    end
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