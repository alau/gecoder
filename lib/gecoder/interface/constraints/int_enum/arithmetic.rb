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
  class MaxExpressionStub < Gecode::Constraints::ExpressionStub
    include Gecode::Constraints::LeftHandSideMethods
    
    private
    
    # Produces an expression with position for the lhs module.
    def expression(params)
      # We extract the integer and continue as if it had been specified as
      # left hand side. This might be elegant, but it could get away with 
      # fewer constraints at times (when only equality is used) and 
      # propagation strength can't be specified. 
      # TODO: cut down on the number of constraints when possible. See if 
      # there's some neat way of getting the above remarks. 
      
      params.update(@params)
      lhs = params[:lhs]
      proxy = @model.int_var(lhs.domain_range)
      lhs = lhs.to_int_var_array if lhs.respond_to? :to_int_var_array
      
      Gecode::Raw::max(@model.active_space, lhs, proxy.bind, 
        Gecode::Raw::ICL_DEF)
      Gecode::Constraints::Int::Expression.new(@model, 
        params.update(:lhs => proxy))
    end
  end
  
  # Describes an expression stub started with an int var enum following by #min.
  class MinExpressionStub < Gecode::Constraints::ExpressionStub
    include Gecode::Constraints::LeftHandSideMethods
    
    private
    
    # Produces an expression with position for the lhs module.
    def expression(params)
      # We extract the integer and continue as if it had been specified as
      # left hand side. This might be elegant, but it could get away with 
      # fewer constraints at times (when only equality is used) and 
      # propagation strength can't be specified. 
      # TODO: cut down on the number of constraints when possible. See if 
      # there's some neat way of getting the above remarks. 
      
      params.update(@params)
      lhs = params[:lhs]
      proxy = @model.int_var(lhs.domain_range)
      lhs = lhs.to_int_var_array if lhs.respond_to? :to_int_var_array
      
      Gecode::Raw::min(@model.active_space, lhs, proxy.bind, 
        Gecode::Raw::ICL_DEF)
      Gecode::Constraints::Int::Expression.new(@model, 
        params.update(:lhs => proxy))
    end
  end
end
