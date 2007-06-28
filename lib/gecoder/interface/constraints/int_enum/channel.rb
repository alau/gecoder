module Gecode::Constraints::IntEnum
  class Expression
    # Posts a channel constraint on the variables in the enum with the specified
    # other enum.
    def channel(enum, options = {})
      if @params[:negate]
        raise Gecode::MissingConstraintError, 'A negated channel constraint ' + 
          'is not implemented.'
      end
    
      @params.update(Gecode::Constraints::OptionUtil.decode_options(options))
      @params.update(:rhs => enum)
      @model.add_constraint Channel::ChannelConstraint.new(@model, @params)
    end
  end
  
  # A module that gathers the classes and modules used in channel constraints.
  module Channel
    # Describes a channel constraint.
    class ChannelConstraint < Gecode::Constraints::Constraint
      def post
        lhs, rhs, strength = @params.values_at(:lhs, :rhs, :strength)
      
        # Bind both sides.
        lhs = lhs.to_int_var_array
        rhs = rhs.to_int_var_array
        
        Gecode::Raw::channel(@model.active_space, lhs, rhs, strength)
      end
    end
  end
end