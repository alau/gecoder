module Gecode
  class Model
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
      
      if elements.map{ |var| var.kind_of? FreeIntVar }.all?
        class <<enum
          include Gecode::IntEnumMethods
        end
      elsif elements.map{ |var| var.kind_of? FreeBoolVar }.all?
        class <<enum
          include Gecode::BoolEnumMethods
        end
      elsif elements.map{ |var| var.kind_of? Fixnum }.all?
        class <<enum
          include Gecode::FixnumEnumMethods
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
    
    # Returns the smallest range that contains the domains of all integer 
    # variables involved.
    def domain_range
      inject(nil) do |range, var|
        next var.min..var.max if range.nil?
        min = var.min
        max = var.max
        range = min..range.last if min < range.first
        range = range.first..max if max > range.last
        range
      end
    end
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
  
  # A module containing the methods needed by enumerations containing fixnums. 
  # Requires that it's included in an enumerable.
  module FixnumEnumMethods
    include EnumMethods
    
    # Returns the smallest range that contains the domains of all integer 
    # variables involved.
    def domain_range
      min..max
    end
  end
end