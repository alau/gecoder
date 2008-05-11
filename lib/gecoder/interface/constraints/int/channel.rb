module Gecode::Constraints::Int
  class Expression
    alias_method :pre_channel_equals, :==
    
    # Constrains the integer variable to be equal to the specified boolean 
    # variable. I.e. constrains the integer variable to be 1 when the boolean
    # variable is true and 0 if the boolean variable is false.
    def ==(bool, options = {})
      unless @params[:lhs].kind_of?(Gecode::FreeIntVar) and 
          bool.kind_of?(Gecode::FreeBoolVar)
        return pre_channel_equals(bool, options)
      end
      
      if @params[:negate]
        raise Gecode::MissingConstraintError, 'A negated channel constraint ' +
          'is not implemented.'
      end
      unless options[:reify].nil?
        raise ArgumentError, 'Reification is not supported by the channel ' + 
          'constraint.'
      end
      
      @params.update(Gecode::Constraints::Util.decode_options(options))
      @params[:rhs] = bool
      @model.add_constraint Channel::ChannelConstraint.new(@model, @params)
    end
    
    alias_comparison_methods
    
    # Adds a channel constraint on the integer variable and the variables in 
    # the specifed enum of boolean variables. Beyond the common options the 
    # channel constraint can also take the following option:
    #
    # [:offset]  Specifies an offset for the integer variable. If the offset is
    #            set to k then the integer variable takes value i+k exactly 
    #            when the variable at index i in the boolean enumration is true 
    #            and the rest are false.
    provide_commutivity(:channel){ |rhs, _| rhs.respond_to? :to_bool_var_array }
  end
  
  # A module that gathers the classes and modules used in channel constraints
  # involving a single integer variable.
  module Channel #:nodoc:
    # Describes a channel constraint that constrains an integer variable to be 
    # 1 if a boolean variable is true, and 0 when the boolean variable is false. 
    # Does not support negation nor reification.
    #
    # == Examples
    #
    #   # The integer variable +x+ must be one exactly when the boolean 
    #   # variable +bool+ is true.
    #   x.must == bool
    class ChannelConstraint < Gecode::Constraints::Constraint
      def post
        lhs, rhs = @params.values_at(:lhs, :rhs)
        Gecode::Raw::channel(@model.active_space, lhs.bind, rhs.bind,
          *propagation_options)
      end
    end
  end
end