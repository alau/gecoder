module Gecode::Constraints::IntEnum
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
      
      util = Gecode::Constraints::Util
      
      # Check that the tuples are correct.
      expected_size = @params[:lhs].size
      util::Extensional.perform_tuple_checks(tuples, expected_size) do |tuple|
        unless tuple.all?{ |x| x.kind_of? Fixnum }
          raise TypeError, 'All tuples must contain Fixnum.'
        end
      end
    
      @params[:tuples] = tuples
      @model.add_constraint Extensional::TupleConstraint.new(@model, 
        @params.update(util.decode_options(options)))
    end
  end
  
  # A module that gathers the classes and modules used in extensional 
  # constraints.
  module Extensional #:nodoc:
    # Describes a tuple constraint, which constrains all the variables in an 
    # enumeration of integer variables to be equal to one of the specified 
    # tuples. Neither negation nor reification is supported.
    # 
    # == Example
    # 
    #   # Constrains the two integer variables in +numbers+ to either have 
    #   # values 1 and 7, or values 47 and 11.
    #   numbers.must_be.in [[1,7], [47,11]]
    #
    #   # The same as above, but preferring speed over low memory usage.
    #   numbers.must_be.in([[1,7], [47,11]], :kind => :speed)
    class TupleConstraint < Gecode::Constraints::Constraint
      def post
        # Bind lhs.
        lhs = @params[:lhs].to_int_var_array

        # Create the tuple set.
        tuple_set = Gecode::Raw::TupleSet.new
        @params[:tuples].each do |tuple|
          tuple_set.add tuple
        end
        tuple_set.finalize

        # Post the constraint.
        Gecode::Raw::extensional(@model.active_space, lhs, tuple_set, 
          *propagation_options)
      end
    end
  end
end
