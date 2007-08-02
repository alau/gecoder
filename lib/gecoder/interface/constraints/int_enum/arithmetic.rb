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
module Gecode::Constraints::IntEnum::Arithmetic #:nodoc:
  # Describes a CompositeStub for the max constraint, which constrains the 
  # maximum value of the integer variables in an enumeration.
  # 
  # == Example
  # 
  #   # The maximum must be positive.
  #   int_enum.max.must > 0
  #   
  #   # The maximum must equal a integer variable +max+.
  #   int_enum.max.must == max
  #   
  #   # The maximum must not be negative. The constraint is reified with the 
  #   # boolean variable +is_negative+ and strength +domain+ is selected.
  #   int_enum.max.must_not_be.less_than(0, :reify => is_negative, 
  #     :strength => :domain)
  class MaxExpressionStub < Gecode::Constraints::Int::CompositeStub
    def constrain_equal(variable, params, constrain)
      enum, strength = @params.values_at(:lhs, :strength)
      if constrain
        variable.must_be.in enum.domain_range
      end
      
      Gecode::Raw::max(@model.active_space, enum.to_int_var_array, 
        variable.bind, strength)
    end
  end
  
  # Describes a CompositeStub for the min constraint, which constrains the 
  # minimum value of the integer variables in an enumeration.
  # 
  # == Example
  # 
  #   # The minimum must be positive.
  #   int_enum.min.must > 0
  #   
  #   # The minimum must equal a integer variable +min+.
  #   int_enum.min.must == min
  #   
  #   # The minimum must not be non-positive. The constraint is reified with the 
  #   # boolean variable +is_positive+ and strength +domain+ is selected.
  #   int_enum.min.must_not_be.less_or_equal(0, :reify => is_positive, 
  #     :strength => :domain)
  class MinExpressionStub < Gecode::Constraints::Int::CompositeStub
    def constrain_equal(variable, params, constrain)
      enum, strength = @params.values_at(:lhs, :strength)
      if constrain
        variable.must_be.in enum.domain_range
      end
      
      Gecode::Raw::min(@model.active_space, enum.to_int_var_array, 
        variable.bind, strength)
    end
  end
end
