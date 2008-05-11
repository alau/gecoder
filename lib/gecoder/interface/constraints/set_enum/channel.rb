module Gecode::Constraints::SetEnum
  class Expression
    # Posts a channel constraint on the variables in the enum with the specified
    # int enum.
    def channel(enum, options = {})
      unless enum.respond_to? :to_int_var_array
        raise TypeError, "Expected integer variable enum, for #{enum.class}."
      end
      if @params[:negate]
        raise Gecode::MissingConstraintError, 'A negated channel constraint ' + 
          'is not implemented.'
      end
      if options.has_key? :reify
        raise ArgumentError, 'The channel constraints does not support the ' +
          'reification option.'
      end
      
      @params.update(Gecode::Constraints::Set::Util.decode_options(options))
      @params.update(:rhs => enum)
      @model.add_constraint Channel::IntChannelConstraint.new(@model, @params)
    end
  end
  
  # A module that gathers the classes and modules used in channel constraints.
  module Channel #:nodoc:
    # Describes a channel constraint which "channels" one enumeration of 
    # integer variables with one enumeration of set variables. The i:th set 
    # in the enumeration of set variables is constrainde to includes the value 
    # of the j:th integer variable. 
    # 
    # Neither reification nor negation is supported.
    # 
    # == Examples
    # 
    #   # +set_enum+ is constrained to channel +int_enum+.
    #   int_enum.must.channel set_enum
    # 
    #   # This is another way of saying the above.
    #   set_enum.must.channel int_enum
    #
    class IntChannelConstraint < Gecode::Constraints::Constraint
      def post
        lhs, rhs = @params.values_at(:lhs, :rhs)
        Gecode::Raw::channel(@model.active_space, rhs.to_int_var_array, 
          lhs.to_set_var_array)
      end
    end
  end
end