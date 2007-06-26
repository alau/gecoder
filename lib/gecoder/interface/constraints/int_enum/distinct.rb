module Gecode
  module IntEnumMethods
    # Specifies offsets to be used with a distinct constraint. The offsets can
    # be specified one by one or as an array of offsets.
    def with_offsets(*offsets)
      if offsets.kind_of? Enumerable
        offsets = *offsets
      end
      params = {:lhs => self, :offsets => offsets}
      return Gecode::Constraints::IntEnum::Distinct::OffsetExpression.new(
        @model, params)
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
    
      @model.add_constraint Distinct::DistinctConstraint.new(@model, 
        @params.update(Gecode::Constraints::OptionUtil.decode_options(options)))
    end
  end
  
  # A module that gathers the classes and modules used in distinct constraints.
  module Distinct
    # Describes an expression started with an int var enum following with
    # #with_offsets .
    class OffsetExpression < Gecode::Constraints::IntEnum::Expression
      include Gecode::Constraints::LeftHandSideMethods
      
      def initialize(model, params)
        @model = model
        @params = params
      end
      
      private
      
      # Produces an expression with offsets for the lhs module.
      def expression(params)
        params.update(@params)
        Gecode::Constraints::IntEnum::Expression.new(@model, params)
      end
    end
    
    # Describes a distinct constraint (optionally with offsets).
    class DistinctConstraint < Gecode::Constraints::Constraint
      def post
        # Bind lhs.
        @params[:lhs] = @params[:lhs].to_int_var_array
        
        # Fetch the parameters to Gecode.
        params = @params.values_at(:offsets, :lhs, :strength)
        params.delete_if{ |x| x.nil? }
        Gecode::Raw::distinct(@model.active_space, *params)
      end
    end
  end
end