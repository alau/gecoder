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
        include Gecode::IntEnumMethods
      end
      enum.model = self
      return enum
    end
  end
  
  # A module containing the methods needed by enumerations containing int 
  # variables. Requires that it's included in an enumerable.
  module IntEnumMethods
    # Returns an int variable array with all the bound variables.
    def to_int_var_array
      elements = to_a
      arr = Gecode::Raw::IntVarArray.new(active_space, elements.size)
      elements.each_with_index{ |var, index| arr[index] = var.bind }
      return arr
    end
    
    attr_accessor :model
    # Gets the current space of the model the array is connected to.
    def active_space
      @model.active_space
    end
  end
end