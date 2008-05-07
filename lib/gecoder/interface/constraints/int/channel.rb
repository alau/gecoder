module Gecode::Constraints::Int
  class Expression
    alias_method :pre_channel_equals, :==
    
    # Constrains the integer variable to be equal to the specified boolean 
    # variable.
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
  end
  
  # A module that gathers the classes and modules used in channel constraints
  # involving a single integer variable.
  module Channel #:nodoc:
    # Describes a channel constraint that constrains an integer variable to be 
    # 1 if a bool variable is true, and false otherwise. Does not support 
    # negation nor reification.
    #
    # == Examples
    #
    #   # The integer variable +x+ must be one exactly when the boolean 
    #   # variable +bool+ is true.
    #   x.must == bool
    class ChannelConstraint < Gecode::Constraints::Constraint
      def post
        lhs, rhs = @params.values_at(:lhs, :rhs)
      
        # Int var array.
        Gecode::Raw::channel(@model.active_space, lhs.bind, rhs.bind,
          *propagation_options)
      end
    end
  end
end