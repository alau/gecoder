module Gecode
  class FreeIntVar
    include Gecode::Constraints::LeftHandSideMethods
    
    private
    
    # Produces an expression for the lhs module.
    def expression(params)
      params.update(:lhs => self)
      Constraints::Int::Expression.new(@model, params)
    end
  end
  
  # A module containing constraints that have int variables as left hand side
  # (but not enumerations).
  module Constraints::Int
    # Describes an integer expression.
    class Expression < Gecode::Constraints::Expression #:nodoc:
    end
    
    # A composite expression which is an int expression with a left hand side 
    # resulting from a previous constraint.
    class CompositeExpression < Gecode::Constraints::CompositeExpression #:nodoc:
      # The block given should take three parameters. The first is the variable 
      # that should be the left hand side, if it's nil then a new one should be
      # created. The second is the has of parameters. The block should return 
      # the variable used as left hand side.
      def initialize(model, params, &block)
        super(Expression, Gecode::FreeIntVar, lambda{ model.int_var }, model, 
          params, &block)
      end
    end
    
    # Describes a stub that produces an int variable, which can then be used 
    # with the normal int variable constraints. An example would be the element
    # constraint.
    #
    #   int_enum[int_var].must > rhs
    #
    # <tt>int_enum[int_var]</tt> produces an int variable which the constraint 
    # <tt>.must > rhs</tt> is then applied to. In the above case two 
    # constraints (and one temporary variable) are required, but in the case of 
    # equality only one constraint is required.
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

require 'gecoder/interface/constraints/int/linear'
require 'gecoder/interface/constraints/int/domain'
require 'gecoder/interface/constraints/int/arithmetic'
require 'gecoder/interface/constraints/int/channel'
