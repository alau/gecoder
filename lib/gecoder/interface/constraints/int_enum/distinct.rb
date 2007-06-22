module Gecode
  module IntEnumMethods
    # Specifies offsets to be used with a distinct constraint. The offsets can
    # be specified one by one or as an array of offsets.
    def with_offsets(*offsets)
      if offsets.kind_of? Enumerable
        offsets = *offsets
      end
      params = {:lhs => self, :space => active_space, :offsets => offsets}
      return Gecode::Constraints::IntEnum::Distinct::OffsetExpression.new(params)
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

      # Bind lhs.
      @params[:lhs] = @params[:lhs].to_int_var_array
      
      # Fetch the parameters to Gecode.
      strength, reif = Gecode::Constraints::OptionUtil.decode_options(options)
      params = @params.values_at(:space, :offsets, :lhs) + [strength, reif]
      params.delete_if{ |x| x.nil? }
      Gecode::Raw::distinct(*params)
    end
  end
  
  # A module that gathers the classes and modules used in distinct constraints.
  module Distinct
    # Describes an expression started with an int var enum following with
    # #with_offsets .
    class OffsetExpression < Gecode::Constraints::IntEnum::Expression
      include Gecode::Constraints::LeftHandSideMethods
      
      def initialize(params)
        @params = params
      end
      
      private
      
      # Produces an expression with offsets for the lhs module.
      def expression(params)
        params.update(@params)
        Gecode::Constraints::IntEnum::Expression.new(params)
      end
    end
  end
end