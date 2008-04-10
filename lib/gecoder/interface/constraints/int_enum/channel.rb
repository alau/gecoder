module Gecode::Constraints::IntEnum
  class Expression
    # Adds a channel constraint on the variables in the enum with the specified
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
  module Channel #:nodoc:
    # Describes a channel constraint which "channels" two enumerations of 
    # integer variables or one enumeration of integer variables and one 
    # enumeration of set variables. Channel constraints are used to give 
    # access to multiple viewpoints when modelling. 
    # 
    # When used on two integer enumeration, the channel constraint can be 
    # thought of as constraining the arrays to be each other's inverses. When 
    # used with an enumeration of sets the i:th set includes the value of the
    # j:th integer.  
    # 
    # Neither reification nor negation is supported. Selecting strength is only 
    # supported when using the constraint between two integer enumerations, 
    # it's not supported when a set enumeration is used.  
    # 
    # == Example
    # 
    # Lets say that we’re modelling a sequence of numbers that must be distinct
    # and that we want access to the following two view simultaneously.
    # 
    # === First view
    # 
    # The sequence is modelled as an array of integer variables where the first 
    # variable holds the value of the first position in the sequence, the 
    # second the value of the second position and so on.
    # 
    #   # n variables with values from 0 to n-1.
    #   elements = int_var_array(n, 0...n)
    #   elements.must_be.distinct
    # 
    # That way +elements+ will contain the actual sequence when the problem has 
    # been solved.
    # 
    # === Second view
    # 
    # The sequence is modelled as the positions of each value in 0..(n-1) in 
    # the sequence. That way the first variable would hold the positions of 0 
    # in the sequence, the second variable would hold the positions of 1 in the 
    # sequence and so on.
    # 
    #   positions = int_var_array(n, 0...n)
    #   positions.must_be.distinct
    # 
    # === Connecting the views
    #   
    # In essence the relationship between the two arrays +elements+ and 
    # +positions+ is that
    # 
    #   elements.map{ |e| e.val }[i] == positions.map{ |p| p.val }.index(i)
    # 
    # for all i in 0..(n-1). This relationship is enforced by the channel 
    # constraint as follows. 
    # 
    #   elements.must.channel positions
    # 
    # == Example (sets)
    # 
    #   # +set_enum+ is constrained to channel +int_enum+.
    #   int_enum.must.channel set_enum
    # 
    #   # This is another way of saying the above.
    #   set_enum.must.channel int_enum
    class ChannelConstraint < Gecode::Constraints::Constraint
      def post
        lhs, rhs = @params.values_at(:lhs, :rhs)
      
        lhs = lhs.to_int_var_array
        if rhs.respond_to? :to_int_var_array
          # Int var array.
          Gecode::Raw::channel(@model.active_space, lhs, rhs.to_int_var_array,
            *propagation_options)
        else
          # Set var array, no strength.
          Gecode::Raw::channel(@model.active_space, lhs, rhs.to_set_var_array)
        end
      end
    end
  end
end