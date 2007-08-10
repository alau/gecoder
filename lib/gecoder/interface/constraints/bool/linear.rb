module Gecode
  class FreeBoolVar
    # Creates a linear expression where the bool variables are summed.
    def +(var)
      Gecode::Constraints::Int::Linear::ExpressionNode.new(self, 
        @model) + var
    end
    
    alias_method :pre_linear_mult, :* if instance_methods.include? '*'

    # Creates a linear expression where the bool variable is multiplied with 
    # a constant integer.
    def *(int)
      if int.kind_of? Fixnum
        Gecode::Constraints::Int::Linear::ExpressionNode.new(self, 
          @model) * int
      else
        pre_linear_mult(int) if respond_to? :pre_linear_mult
      end
    end
    
    # Creates a linear expression where the specified variable is subtracted 
    # from this one.
    def -(var)
      Gecode::Constraints::Int::Linear::ExpressionNode.new(self, 
        @model) - var
    end
  end
end