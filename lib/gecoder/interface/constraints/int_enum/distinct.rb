module Gecode
  module IntEnumMethods
    # Specifies offsets to be used with a distinct constraint. The offsets can
    # be specified one by one or as an array of offsets.
    def with_offsets(*offsets)
      if offsets.kind_of? Enumerable
        offsets = *offsets
      end
      params = {:lhs => self, :offsets => offsets}
      
      Gecode::Constraints::SimpleExpressionStub.new(@model, params) do |m, ps|
        Gecode::Constraints::IntEnum::Expression.new(m, ps)
      end
    end
  end
end

module Gecode::Constraints::IntEnum
  class Expression
    # Posts a distinct constraint on the variables in the enum.
    def distinct(options = {})
      if @params[:negate]
        # The best we could implement it as from here would be a bunch of 
        # reified pairwise equality constraints. 
        raise Gecode::MissingConstraintError, 'A negated distinct is not ' + 
          'implemented.'
      end
      unless options[:reify].nil?
        raise ArgumentError, 'Reification is not supported by the distinct ' + 
          'constraint.'
      end
      
      @model.add_constraint Distinct::DistinctConstraint.new(@model, 
        @params.update(Gecode::Constraints::Util.decode_options(options)))
    end
  end
  
  # A module that gathers the classes and modules used in distinct constraints.
  module Distinct #:nodoc:
    # Describes a distinct constraint, which constrains all integer variables 
    # in an enumeration to be distinct (different). The constraint can also be
    # used with constant offsets, so that the variables, with specified offsets
    # added, must be distinct.
    # 
    # The constraint does not support negation nor reification.
    # 
    # == Examples
    # 
    #   # Constrains all variables in +int_enum+ to be assigned different 
    #   # values.
    #   int_enum.must_be.distinct
    #   
    #   # The same as above, but also selects that the strength +domain+ should
    #   # be used.
    #   int_enum.must_be.distinct(:strength => :domain)
    #   
    #   # Uses the offset to constrain that no number may be the previous number
    #   # incremented by one.
    #   numbers = int_var_array(8, 0..9)
    #   numbers.with_offset((1..numbers.size).to_a.reverse).must_be.distinct
    class DistinctConstraint < Gecode::Constraints::Constraint
      def post
        # Bind lhs.
        @params[:lhs] = @params[:lhs].to_int_var_array
        
        # Fetch the parameters to Gecode.
        params = @params.values_at(:offsets, :lhs)
        params.delete_if{ |x| x.nil? }
        params.concat propagation_options
        Gecode::Raw::distinct(@model.active_space, *params)
      end
    end
  end
end