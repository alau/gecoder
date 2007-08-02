module Gecode
  class FreeSetVar
    # Starts a constraint on the size of the set.
    def size
      params = {:lhs => self}
      Gecode::Constraints::Set::Cardinality::SizeExpressionStub.new(
        @model, params)
    end
  end
end

module Gecode::Constraints::Set
  # A module that gathers the classes and modules used in cardinality 
  # constraints.
  module Cardinality #:nodoc:
    # Describes a cardinality constraint specifically for ranges. This is just
    # a special case which is used instead of the more general composite 
    # constraint when the target cardinality is a range. 
    class CardinalityConstraint < Gecode::Constraints::Constraint #:nodoc:
      def post
        var, range = @params.values_at(:lhs, :range)
        Gecode::Raw::cardinality(@model.active_space, var.bind, range.first, 
          range.last)
      end
    end
    
    # A custom composite stub to change the composite expression used.
    class CompositeStub < Gecode::Constraints::CompositeStub #:nodoc:
      def initialize(model, params)
        super(Expression, model, params)
      end
    end
    
    # Describes a cardinality expression started with set.size.must .
    class Expression < Gecode::Constraints::Int::CompositeExpression #:nodoc:
      def in(range)
        if range.kind_of?(Range) and !@params[:negate]
          @params.update(:range => range)
          @model.add_constraint CardinalityConstraint.new(@model, @params)
        else
          super(range)
        end
      end
    end
    
    # Describes a CompositeStub for the cardianlity constraint which constrains
    # the cardianlity (size) of a set.
    # 
    # == Example
    # 
    #   # The size of +set+ must be within 1..17
    #   set.size.must_be.in 1..17
    #   
    #   # The size must equal the integer variable +size+.
    #   set.size.must == size
    #   
    #   # The size must not be larger than 17
    #   set.size.must_not > 17
    #   
    #   # We reify the above with a boolean variable called +is_not_large+ and 
    #   # select the strength +domain+.
    #   set.size.must_not_be.larger_than(17, :reify => is_not_large, 
    #     :strength => :domain)
    class SizeExpressionStub < CompositeStub
      def constrain_equal(variable, params, constrain)
        lhs = @params[:lhs]
        if constrain
          variable.must_be.in lhs.lower_bound.size..lhs.upper_bound.size
        end
        
        Gecode::Raw::cardinality(@model.active_space, lhs.bind, variable.bind)
      end
    end
  end
end