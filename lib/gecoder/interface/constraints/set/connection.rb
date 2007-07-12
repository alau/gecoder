module Gecode
  class FreeSetVar
    # Starts a constraint on the minimum value of the set.
    def min
      params = {:lhs => self}
      Gecode::Constraints::Set::Connection::MinExpressionStub.new(@model, params)
    end
    
    # Starts a constraint on the maximum value of the set.
    def max
      params = {:lhs => self}
      Gecode::Constraints::Set::Connection::MaxExpressionStub.new(@model, params)
    end
  end
end

module Gecode::Constraints::Set
  # A module that gathers the classes and modules used in connection 
  # constraints.
  module Connection
    # Describes an expression stub started with an int var following by #min.
    class MinExpressionStub < Gecode::Constraints::Int::CompositeStub
      def constrain_equal(variable, params)
        set = params[:lhs]
        if variable.nil?
          variable = @model.int_var(set.lub_min, set.glb_min)
        end
        
        Gecode::Raw::min(@model.active_space, set.bind, variable.bind)
        return variable
      end
    end
    
    # Describes an expression stub started with an int var following by #max.
    class MaxExpressionStub < Gecode::Constraints::Int::CompositeStub
      def constrain_equal(variable, params)
        set = params[:lhs]
        if variable.nil?
          variable = @model.int_var(set.lub_max, set.glb_max)
        end
        
        Gecode::Raw::max(@model.active_space, set.bind, variable.bind)
        return variable
      end
    end
  end
end