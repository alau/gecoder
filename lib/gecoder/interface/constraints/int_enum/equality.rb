module Gecode::Constraints::IntEnum
  class Expression
    # Posts an equality constraint on the variables in the enum.
    def equal(options = {})
      if @params[:negate]
        # The best we could implement it as from here would be a bunch of 
        # reified pairwise inequality constraints.
        raise Gecode::MissingConstraintError, 'A negated equality is not ' + 
          'implemented.'
      end
    
      @model.add_constraint Equality::EqualityConstraint.new(@model, 
        @params.update(Gecode::Constraints::Util.decode_options(options)))
    end
  end
  
  # A module that gathers the classes and modules used in equality constraints.
  module Equality
    # Describes an equality constraint.
    class EqualityConstraint < Gecode::Constraints::Constraint
      def post
        # Bind lhs.
        @params[:lhs] = @params[:lhs].to_int_var_array
        
        # Fetch the parameters to Gecode.
        params = @params.values_at(:lhs, :strength)
        Gecode::Raw::eq(@model.active_space, *params)
      end
    end
  end
end