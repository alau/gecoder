module Gecode::Constraints::BoolEnum
  class Expression
    # Posts an equality constraint on the variables in the enum.
    def in(tuples, options = {})
      if @params[:negate]
        raise Gecode::MissingConstraintError, 'A negated tuple constraint is ' +
          'not implemented.'
      end
      unless options[:reify].nil?
        raise ArgumentError, 'Reification is not supported by the tuple ' + 
          'constraint.'
      end
      unless tuples.respond_to?(:each) and 
          tuples.all?{ |tuple| tuple.respond_to?(:each) }
        raise TypeError, 'Expected an enumeration with tuples, got ' + 
          "#{tuples.class}."
      end
      unless tuples.all?{ |tuple| 
          tuple.all?{ |x| x.kind_of?(TrueClass) or x.kind_of?(FalseClass) }}
        raise TypeError, 'All tuples must contain booleans.'
      end
    
      @params[:tuples] = tuples
      @model.add_constraint Extensional::TupleConstraint.new(@model, 
        @params.update(Gecode::Constraints::Util.decode_options(options)))
    end
  end
  
  # A module that gathers the classes and modules used in extensional 
  # constraints.
  module Extensional #:nodoc:
    # Describes a tuple constraint, which constrains the variables in an 
    # boolean enumeration to be equal to one of the specified tuples. Neither 
    # negation nor reification is supported.
    # 
    # == Example
    # 
    #   # Constrains the three boolean variables in +bools+ to either
    #   # be true, false, true, or false, false, true.
    #   bools.must_be.in [[true, false, true], [false, false, true]]
    #
    #   # The same as above, but preferring speed over low memory usage.
    #   bools.must_be.in([[true, false, true], [false, false, true]], 
    #     :kind => :speed)
    class TupleConstraint < Gecode::Constraints::Constraint
      def post
        # Bind lhs.
        lhs = @params[:lhs].to_bool_var_array

        # Create the tuple set.
        tuple_set = Gecode::Raw::TupleSet.new
        @params[:tuples].each do |tuple|
          tuple_set.add tuple.map{ |b| b ? 1 : 0 }
        end
        tuple_set.finalize

        # Post the constraint.
        Gecode::Raw::extensional(@model.active_space, lhs, tuple_set, 
          *propagation_options)
      end
    end
  end
end
