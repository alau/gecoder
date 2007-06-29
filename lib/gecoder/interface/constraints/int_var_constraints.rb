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
    class Expression < Gecode::Constraints::Expression
    end
  end
end

require 'gecoder/interface/constraints/int/linear'
require 'gecoder/interface/constraints/int/domain'
require 'gecoder/interface/constraints/int/arithmetic'
