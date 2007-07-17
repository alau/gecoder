module Gecode
  class FreeSetVar
    # Starts a constraint on the size of the set.
    def size
      params = {:lhs => self}
      Gecode::Constraints::Set::Cardinality::SizeExpressionStub.new(@model, params)
    end
  end
end

module Gecode::Constraints::Set
  # A module that gathers the classes and modules used in cardinality 
  # constraints.
  module Cardinality
    # Describes a cardinality constraint.
    class CardinalityConstraint < Gecode::Constraints::Constraint
      def post
        var, range = @params.values_at(:lhs, :range)
        Gecode::Raw::cardinality(@model.active_space, var.bind, range.first, 
          range.last)
      end
    end
    
    # A custom composite stub to change the composite expression used.
    class CompositeStub < Gecode::Constraints::CompositeStub
      def initialize(model, params)
        super(Expression, model, params)
      end
    end
    
    # Describes a cardinality expression started with set.size.must .
    class Expression < Gecode::Constraints::Int::CompositeExpression
      def in(range)
        if range.kind_of?(Range) and !@params[:negate]
          @params.update(:range => range)
          @model.add_constraint CardinalityConstraint.new(@model, @params)
        else
          super(range)
        end
      end
    end
    
    # Describes an expression stub started with a set variable followed by 
    # #size .
    class SizeExpressionStub < CompositeStub
      def constrain_equal(variable, params)
        lhs = @params[:lhs]
        if variable.nil?
          variable = @model.int_var(lhs.lower_bound.size, lhs.upper_bound.size)
        end
        
        @model.add_interaction do 
          Gecode::Raw::cardinality(@model.active_space, lhs.bind, variable.bind)
        end
        return variable
      end
    end
  end
end