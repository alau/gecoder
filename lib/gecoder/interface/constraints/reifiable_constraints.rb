module Gecode::Constraints
  # Base class for all reifiable constraints.
  class ReifiableConstraint < Constraint
    # Gets the reification variable of the constraint, nil if none exists.
    def reification_var
      @params[:reify]
    end
    
    # Sets the reification variable of the constraint, nil if none should be
    # used.
    def reification_var=(new_var)
      @params[:reify] = new_var
    end
  end
end