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
  end
end

require 'gecoder/interface/constraints/set/domain'
require 'gecoder/interface/constraints/set/relation'
require 'gecoder/interface/constraints/set/cardinality'
