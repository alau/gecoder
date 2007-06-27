module Gecode
  class Model
    private
    
    # Wraps a custom enumerable so that constraints can be specified using it.
    # The argument is altered and returned. 
    def wrap_enum(enum)
      unless enum.kind_of? Enumerable
        raise TypeError, 'Only enumerables can be wrapped.'
      end
      elements = enum.to_a
      if elements.empty?
        raise ArgumentError, 'Enumerable must not be empty.'
      end
      
      if elements.first.kind_of? FreeIntVar
        class <<enum
          include Gecode::IntEnumMethods
        end
      elsif elements.first.kind_of? FreeBoolVar
        class <<enum
          include Gecode::BoolEnumMethods
        end
      else
        raise TypeError, "Enumerable doesn't contain variables #{enum.inspect}."
      end
      
      enum.model = self
      return enum
    end
  end
  
  # A module containing the methods needed by enumerations containing variables.
  module EnumMethods
    attr_accessor :model
    # Gets the current space of the model the array is connected to.
    def active_space
      @model.active_space
    end
  end
  
  # A module containing the methods needed by enumerations containing int 
  # variables. Requires that it's included in an enumerable.
  module IntEnumMethods
    include EnumMethods
  
    # Returns an int variable array with all the bound variables.
    def to_int_var_array
      elements = to_a
      arr = Gecode::Raw::IntVarArray.new(active_space, elements.size)
      elements.each_with_index{ |var, index| arr[index] = var.bind }
      return arr
    end
    alias_method :to_var_array, :to_int_var_array
  end
  
  # A module containing the methods needed by enumerations containing boolean
  # variables. Requires that it's included in an enumerable.
  module BoolEnumMethods
    include EnumMethods
  
    # Returns a bool variable array with all the bound variables.
    def to_bool_var_array
      elements = to_a
      arr = Gecode::Raw::BoolVarArray.new(active_space, elements.size)
      elements.each_with_index{ |var, index| arr[index] = var.bind }
      return arr
    end
    alias_method :to_var_array, :to_bool_var_array
  end
end