module Gecode::Constraints::Bool
  class Expression
    alias_method :pre_channel_equals, :==
    
    # Constrains the boolean variable to be equal to the specified integer 
    # variable.
    def ==(int, options = {})
      unless @params[:lhs].kind_of?(Gecode::FreeBoolVar) and 
          int.kind_of?(Gecode::FreeIntVar)
        return pre_channel_equals(int, options)
      end
      
      if @params[:negate]
        raise Gecode::MissingConstraintError, 'A negated channel constraint ' +
          'is not implemented.'
      end
      
      # Provide commutivity to the corresponding int variable constraint.
      int.must.equal(@params[:lhs], options)
    end
    
    alias_comparison_methods
  end
end
