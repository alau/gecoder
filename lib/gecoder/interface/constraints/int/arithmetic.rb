class Gecode::FreeIntVar
  # Initiates an arithmetic absolute value constraint.
  def abs
    Gecode::Constraints::Int::Arithmetic::AbsExpressionStub.new(@model, 
      :lhs => self)
  end
  
  # Creates a linear expression where the int variable is multiplied with 
  # a constant integer.
  alias_method :pre_arith_mult, :* if instance_methods.include? '*'
  def *(var)
    if var.kind_of? Gecode::FreeIntVar
      Gecode::Constraints::Int::Arithmetic::MultExpressionStub.new(
        @model, :lhs => self, :var => var)
    else
      pre_arith_mult(var) if respond_to? :pre_arith_mult
    end
  end
end

# A module that gathers the classes and modules used by arithmetic constraints.
module Gecode::Constraints::Int::Arithmetic 
  # Describes an expression stub started with an integer variable followed by 
  # #abs .
  class AbsExpressionStub < Gecode::Constraints::Int::CompositeStub
    def constrain_equal(variable, params)
      lhs, strength = @params.values_at(:lhs, :strength)
      if variable.nil?
        variable = @model.int_var(lhs.min..lhs.max)
      end
      
      Gecode::Raw::abs(@model.active_space, lhs.bind, variable.bind, strength)
      return variable
    end
  end
  
  # Describes an expression stub started with an integer variable followed by 
  # #* .
  class MultExpressionStub < Gecode::Constraints::Int::CompositeStub
    def constrain_equal(variable, params)
      lhs, lhs2, strength = @params.values_at(:lhs, :var, :strength)
      if variable.nil?
        a_min = lhs.min; a_max = lhs.max
        b_min = lhs2.min; b_max = lhs2.max
        products = [a_min*b_min, a_min*b_max, a_max*b_min, a_max*b_max]
        variable = @model.int_var(products.min..products.max)
      end

      Gecode::Raw::mult(@model.active_space, lhs.bind, lhs2.bind, 
        variable.bind, strength)
      return variable
    end
  end
end
