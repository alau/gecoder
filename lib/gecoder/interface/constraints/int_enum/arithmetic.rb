module Gecode::IntEnumMethods
  # Starts an arithmetic max constraint. This overrides the normal enum max, but
  # that's not a problem since variables are not implemented to be comparable.
  def max
    return Gecode::Constraints::IntEnum::Arithmetic::MaxExpressionStub.new(
      @model, :lhs => self)
  end
  
  # Starts an arithmetic min constraint. This overrides the normal enum min, but
  # that's not a problem since variables are not implemented to be comparable.
  def min
    return Gecode::Constraints::IntEnum::Arithmetic::MinExpressionStub.new(
      @model, :lhs => self)
  end
end

# A module that gathers the classes and modules used by arithmetic constraints.
module Gecode::Constraints::IntEnum::Arithmetic 
  # Describes an expression stub started with an int var enum following by #max.
  class MaxExpressionStub < Gecode::Constraints::Int::CompositeStub
    def constrain_equal(variable, params)
      enum, strength = @params.values_at(:lhs, :strength)
      if variable.nil?
        variable = @model.int_var(enum.domain_range)
      end
      
      Gecode::Raw::max(@model.active_space, enum.to_int_var_array, 
        variable.bind, strength)
      return variable
    end
  end
  
  # Describes an expression stub started with an int var enum following by #min.
  class MinExpressionStub < Gecode::Constraints::Int::CompositeStub
    def constrain_equal(variable, params)
      enum, strength = @params.values_at(:lhs, :strength)
      if variable.nil?
        variable = @model.int_var(enum.domain_range)
      end
      
      Gecode::Raw::min(@model.active_space, enum.to_int_var_array, 
        variable.bind, strength)
      return variable
    end
  end
end
