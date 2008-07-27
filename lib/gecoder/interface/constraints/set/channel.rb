module Gecode::Constraints::Set
  class Expression
    # Adds a channel constraint on the set variable with the specified enum of 
    # boolean variables.
    def channel(bool_enum, options = {})
      if @params[:negate]
        raise Gecode::MissingConstraintError, 'A negated channel constraint ' + 
          'is not implemented.'
      end
      if options.has_key? :reify
        raise ArgumentError, 'The channel constraint does not support the ' + 
          'reification option.'
      end
      unless bool_enum.respond_to? :to_bool_var_array
        raise TypeError, 'Expected an enum of bool variables, ' + 
          "got #{bool_enum.class}."
      end
      
      @params.update(:rhs => bool_enum)
      @params.update Gecode::Constraints::Set::Util.decode_options(options)
      @model.add_constraint Channel::ChannelConstraint.new(@model, @params)
    end
  end
  
  # A module that gathers the classes and modules used in channel constraints
  # involving one set variable and a boolean enum.
  module Channel #:nodoc:
    # Describes a channel constraint that "channels" a set variable and an
    # enumerations of boolean variables. This constrains the set variable to
    # include value i exactly when the variable at index i in the boolean
    # enumeration is true.
    # 
    # Neither reification nor negation is supported. The boolean enum and set
    # can be interchanged.
    #
    # == Examples
    #
    # # Constrains the enumeration of boolean variables called +bools+ to at
    # # least have the first and third variables set to true 
    # set.must_be.superset_of [0, 2]
    # set.must.channel bools
    #
    # # An alternative way of writing the above.
    # set.must_be.superset_of [0, 2]
    # bools.must.channel set
    class ChannelConstraint < Gecode::Constraints::Constraint
      def post
        lhs, rhs = @params.values_at(:lhs, :rhs)
        Gecode::Raw::channel(@model.active_space, rhs.to_bool_var_array, 
          lhs.bind)
      end
    end
  end
end
