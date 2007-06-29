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
  class AbsExpressionStub < Gecode::Constraints::ExpressionStub
    include Gecode::Constraints::LeftHandSideMethods
    
    private
    
    # Produces a proxy expression for the lhs module.
    def expression(params)
      # We extract the integer and continue as if it had been specified as
      # left hand side. This might be elegant, but it could get away with 
      # fewer constraints at times (when only equality is used) and 
      # propagation strength can't be specified. 
      # TODO: cut down on the number of constraints when possible. See if 
      # there's some neat way of getting the above remarks. 
      
      params.update(@params)
      lhs = params[:lhs]
      proxy = @model.int_var(lhs.min..lhs.max)
      lhs = lhs.bind
      
      Gecode::Raw::abs(@model.active_space, lhs, proxy.bind, 
        Gecode::Raw::ICL_DEF)
      Gecode::Constraints::Int::Expression.new(@model, 
        params.update(:lhs => proxy))
    end
  end
  
  # Describes an expression stub started with an integer variable followed by 
  # #* .
  class MultExpressionStub < Gecode::Constraints::ExpressionStub
    include Gecode::Constraints::LeftHandSideMethods
    
    private
    
    # Produces a proxy expression for the lhs module.
    def expression(params)
      # We extract the integer and continue as if it had been specified as
      # left hand side. This might be elegant, but it could get away with 
      # fewer constraints at times (when only equality is used) and 
      # propagation strength can't be specified. 
      # TODO: cut down on the number of constraints when possible. See if 
      # there's some neat way of getting the above remarks. 
      
      params.update(@params)
      lhs, var = params.values_at(:lhs, :var)
      proxy = @model.int_var(-(lhs.min*var.min).abs..(lhs.max*var.max).abs) # Sloppy
      
      Gecode::Raw::mult(@model.active_space, lhs.bind, var.bind, proxy.bind, 
        Gecode::Raw::ICL_DEF)
      Gecode::Constraints::Int::Expression.new(@model, 
        params.update(:lhs => proxy))
    end
  end
end
