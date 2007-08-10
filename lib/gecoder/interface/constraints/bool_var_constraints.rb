module Gecode
  class FreeBoolVar
    include Gecode::Constraints::LeftHandSideMethods
    
    private
    
    # Produces an expression for the lhs module.
    def expression(params)
      params.update(:lhs => self)
      Constraints::Bool::Expression.new(@model, params)
    end
  end
  
  # A module containing constraints that have int variables as left hand side
  # (but not enumerations).
  module Constraints::Bool
    # Describes a boolean expression.
    class Expression < Gecode::Constraints::Expression #:nodoc:
    end
    
    # A composite expression which is an bool expression with a left hand side 
    # resulting from a previous constraint.
    class CompositeExpression < Gecode::Constraints::CompositeExpression #:nodoc:
      # The block given should take three parameters. The first is the variable 
      # that should be the left hand side, if it's nil then a new one should be
      # created. The second is the has of parameters. The block should return 
      # the variable used as left hand side.
      def initialize(model, params, &block)
        super(Expression, Gecode::FreeBoolVar, lambda{ model.bool_var }, model,
          params, &block)
      end
      
      # Override to also deal with constant booleans.
      def true(options = {})
        # We don't need any additional constraints.
        @params.update Gecode::Constraints::Util.decode_options(options)
        @model.add_interaction do
          @constrain_equal_proc.call(!@params[:negate], @params)
        end
      end
      
      # Override to also deal with constant booleans.
      def false(options = {})
        # We don't need any additional constraints.
        @params.update Gecode::Constraints::Util.decode_options(options)
        @model.add_interaction do
          @constrain_equal_proc.call(@params[:negate], @params)
        end
      end
    end
    
    # Describes a stub that produces an int variable, which can then be used 
    # with the normal int variable constraints. An example would be the 
    # conjunction constraint.
    #
    #   bools.conjunction.must == b1 | b2
    #
    # <tt>bools.conjunction</tt> produces a boolean variable which the 
    # constraint <tt>.must == b1 | b2</tt> is then applied to. In the above 
    # case two constraints (and one temporary variable) are required, but in 
    # the case of equality only one constraint is required.
    # 
    # Whether a constraint involving a reification stub supports negation, 
    # reification, strength options and so on depends on the constraint on the
    # right hand side.
    class CompositeStub < Gecode::Constraints::CompositeStub
      def initialize(model, params)
        super(CompositeExpression, model, params)
      end
    end
  end
end

require 'gecoder/interface/constraints/bool/boolean'
require 'gecoder/interface/constraints/bool/linear'
