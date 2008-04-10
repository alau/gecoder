module Gecode::Constraints::SetEnum
  class Expression
    # Adds a constraint on the sets that specifies that they must have at most
    # one element in common. The "option" :size must be specified, the sets 
    # will be constrained to that size.
    def at_most_share_one_element(options = {})
      unless options.has_key? :size
        raise ArgumentError, 'Option :size has to be specified.'
      end
      unless options.size == 1
        raise ArgumentError, 'Only the option :size is accepted, got ' + 
          "#{options.keys.join(', ')}."
      end
      if @params[:negate]
        raise Gecode::MissingConstraintError, 'A negated atmost one ' + 
          'constrain is not implemented.'
      end
      
      @model.add_constraint Distinct::AtMostOneConstraint.new(
        @model, @params.update(options))
    end
  end
  
  # A module that gathers the classes and modules used in distinct constraints.
  module Distinct #:nodoc:
    # Describes an at most one constraint, which constrains all pairs of set 
    # variables in the enumeration to at most have one element in common and be 
    # of a specified size. Providing a size is not optional.
    # 
    # Neither negation nor reification is supported.
    # 
    # == Examples
    # 
    #   # All set variables in +sets+ must have cardinality 17 and no pair may
    #   # have more than one element in common.
    #   sets.must.at_most_share_one_element(:size => 17)
    class AtMostOneConstraint < Gecode::Constraints::Constraint
      def post
        sets, size = @params.values_at(:lhs, :size)
        Gecode::Raw::atmostOne(@model.active_space, sets.to_set_var_array, size)
      end
    end
  end
end