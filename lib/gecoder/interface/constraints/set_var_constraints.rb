module Gecode
  class FreeSetVar
    include Gecode::Constraints::LeftHandSideMethods
    
    private
    
    # Produces an expression for the lhs module.
    def expression(params)
      params.update(:lhs => self)
      Constraints::Set::Expression.new(@model, params)
    end
  end
  
  # A module containing constraints that have set variables as left hand side
  # (but not enumerations).
  module Constraints::Set
    # An expression with a set as left hand side.
    class Expression < Gecode::Constraints::Expression
    end
    
    # Utility methods for sets.
    module Util
      module_function
      def decode_options(options)
        if options.has_key? :strength
          raise ArgumentError, 'Set constraints do not support the strength ' +
            'option.'
        end
        Gecode::Constraints::Util.decode_options(options)
      end
    end
    
    # A composite expression which is an set expression with a left hand side 
    # resulting from a previous constraint.
    class CompositeExpression < Gecode::Constraints::CompositeExpression
      # The block given should take three parameters. The first is the variable 
      # that should be the left hand side, if it's nil then a new one should be
      # created. The second is the has of parameters. The block should return 
      # the variable used as left hand side.
      def initialize(model, params, &block)
        super(Expression, Gecode::FreeSetVar, lambda{ model.set_var }, model,
          params, &block)
      end
    end
    
    # Describes a stub that produces a set variable, which can then be used with 
    # the normal set variable constraints. An example of a set composite 
    # constraints would be set selection.
    #
    #   sets[int_var].must_be.subset_of(another_set)
    # 
    # "sets[int_var]" produces a bool variable which the constraint 
    # ".must_be.subset_of(another_set)" is then applied to.In the above case 
    # two constraints (and one temporary variable) are required, but in the 
    # case of equality only one constraint is required.
    class CompositeStub < Gecode::Constraints::CompositeStub
      def initialize(model, params)
        super(CompositeExpression, model, params)
      end
    end
  end
end

require 'gecoder/interface/constraints/set/domain'
require 'gecoder/interface/constraints/set/relation'
require 'gecoder/interface/constraints/set/cardinality'
require 'gecoder/interface/constraints/set/connection'
