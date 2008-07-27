module Gecode::Constraints::BoolEnum
  class Expression
    # Adds a channel constraint on the variables in the enum with the specified
    # integer variable. Beyond the common options the channel constraint can
    # also take the following option:
    #
    # [:offset]  Specifies an offset for the integer variable. If the offset is
    #            set to k then the integer variable takes value i+k exactly 
    #            when the variable at index i in the boolean enumeration is true 
    #            and the rest are false.
    def channel(int_var, options = {})
      if @params[:negate]
        raise Gecode::MissingConstraintError, 'A negated channel constraint ' + 
          'is not implemented.'
      end
      if options.has_key? :reify
        raise ArgumentError, 'The channel constraint does not support the ' + 
          'reification option.'
      end
      unless int_var.kind_of? Gecode::FreeIntVar
        raise TypeError, "Expected an integer variable, got #{int_var.class}."
      end
      
      @params.update(:rhs => int_var, :offset => options.delete(:offset) || 0)
      @params.update(Gecode::Constraints::Util.decode_options(options))
      @model.add_constraint Channel::ChannelConstraint.new(@model, @params)
    end
  end
  
  # A module that gathers the classes and modules used in channel constraints
  # involving one boolean enum and one integer variable.
  module Channel #:nodoc:
    # Describes a channel constraint that "channels" an enumeration of 
    # boolean variables with an integer variable. This constrains the integer
    # variable to take value i exactly when the variable at index i in the 
    # boolean enumeration is true and the others are false.
    # 
    # Neither reification nor negation is supported. The int variable
    # and the enumeration can be interchanged.
    #
    # == Examples
    #
    # # Constrains the enumeration called +option_is_selected+ to be false in the
    # # first four positions and have exactly one true variable in the other. 
    # option_is_selected.must.channel selected_option_index 
    # selected_option_index.must_be > 3
    #
    # # Constrains the enumeration called +option_is_selected+ to be false in the
    # # first five positions and have exactly one true variable in the other. 
    # selected_option_index.must.channel(option_is_selected, :offset => 1) 
    # selected_option_index.must_be > 3
    class ChannelConstraint < Gecode::Constraints::Constraint
      def post
        lhs, rhs, offset = @params.values_at(:lhs, :rhs, :offset)
        Gecode::Raw::channel(@model.active_space, lhs.to_bool_var_array, 
          rhs.bind, offset, *propagation_options)
      end
    end
  end
end
