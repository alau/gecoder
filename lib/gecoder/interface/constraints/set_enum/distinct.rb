module Gecode::Constraints::SetEnum
  class Expression
    # Adds a distinct constraint on the sets in the enum. The "option" :size 
    # must be specified, the sets will be constrained to that size.
    def distinct(options = {})
      unless options.has_key? :size
        raise ArgumentError, 'Option :size has to be specified.'
      end
      unless options.size == 1
        raise ArgumentError, 'Only the option :size is accepted, got ' + 
          "#{options.keys.join(', ')}."
      end
      if @params[:negate]
        raise Gecode::MissingConstraintError, 'A negated distinct is not ' + 
          'implemented.'
      end
      
      @model.add_constraint Distinct::DistinctConstraint.new(
        @model, @params.update(options))
    end
    
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
  module Distinct
    # Describes a set distinct constraint.
    class DistinctConstraint < Gecode::Constraints::Constraint
      def post
        sets, size = @params.values_at(:lhs, :size)
        Gecode::Raw::distinct(@model.active_space, sets.to_set_var_array, size)
      end
    end
    
    # Describes an at most one set constraint.
    class AtMostOneConstraint < Gecode::Constraints::Constraint
      def post
        sets, size = @params.values_at(:lhs, :size)
        Gecode::Raw::atmostOne(@model.active_space, sets.to_set_var_array, size)
      end
    end
  end
end