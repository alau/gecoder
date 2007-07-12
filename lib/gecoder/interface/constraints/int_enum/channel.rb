module Gecode::Constraints::IntEnum
  class Expression
    # Posts a channel constraint on the variables in the enum with the specified
    # other set or int enum.
    def channel(enum, options = {})
      if @params[:negate]
        raise Gecode::MissingConstraintError, 'A negated channel constraint ' + 
          'is not implemented.'
      end
      unless enum.respond_to?(:to_int_var_array) or 
          enum.respond_to?(:to_set_var_array)
        raise TypeError, "Expected int or set enum, got #{enum.class}."
      end
      
      @params.update(Gecode::Constraints::Util.decode_options(options))
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
      
        lhs = lhs.to_int_var_array
        if rhs.respond_to? :to_int_var_array
          # Int var array.
          Gecode::Raw::channel(@model.active_space, lhs, rhs.to_int_var_array,
            strength)
        else
          # Set var array, no strength.
          Gecode::Raw::channel(@model.active_space, lhs, rhs.to_set_var_array)
        end
      end
    end
  end
end