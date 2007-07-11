module Gecode
  class FreeSetVar
    # Starts a constraint on all the size of the set.
    def size
      params = {:lhs => self}
      Gecode::Constraints::SimpleExpressionStub.new(@model, params) do |m, ps|
        Gecode::Constraints::Set::Cardinality::Expression.new(m, ps)
      end
    end
  end
end

module Gecode::Constraints::Set
  # A module that gathers the classes and modules used in cardinality 
  # constraints.
  module Cardinality
    # Describes a cardinality expression started with set.size.must .
    class Expression < Gecode::Constraints::Expression
      def in(range)
        unless range.kind_of? Range
          raise TypeError, "Expected Range, got #{range.class}."
        end
        if @params[:negate]
          raise Gecode::MissingConstraintError, 'A negated cardinality ' + 
            'constraint is not implemented.'
        end
        
        @params.update(:range => range)
        @model.add_constraint CardinalityConstraint.new(@model, @params)
      end
    end

    # Describes a cardinality constraint.
    class CardinalityConstraint < Gecode::Constraints::Constraint
      def post
        var, range = @params.values_at(:lhs, :range)
        Gecode::Raw::cardinality(@model.active_space, var.bind, range.first, 
          range.last)
      end
    end
  end
end