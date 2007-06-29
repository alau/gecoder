module Gecode
  module IntEnumMethods
    # Initiates a sort constraint.
    def sorted
      Gecode::Constraints::IntEnum::Sort::ExpressionStub.new(@model, 
        :lhs => self)
    end
    
    # Initiates a sort constraint.
    def sorted_with(indices)
      unless indices.respond_to? :to_int_var_array
        raise TypeError, 'Expected indices to be int var enum, got: ' + 
          "#{indices.class}."
      end
    
      Gecode::Constraints::IntEnum::Sort::ExpressionStub.new(@model, 
        :lhs => self, :indices => indices)
    end
  end
end

module Gecode::Constraints::IntEnum
  # A module that gathers the classes and modules used in sort constraints.
  module Sort
    # Describes an expression started with an int var enum followed by #sorted.
    class ExpressionStub < Gecode::Constraints::ExpressionStub
      include Gecode::Constraints::LeftHandSideMethods
      
      private
      
      # Produces an expression for the lhs module.
      def expression(params)
        params.update(@params)
        Gecode::Constraints::IntEnum::Sort::Expression.new(@model, params)
      end
    end
    
    # Describes an expression started with an int var enum followed by #sorted
    # ans then some form of must*.
    class Expression < Gecode::Constraints::IntEnum::Expression
      def ==(enum, options = {})
        if @params[:negate]
          raise Gecode::MissingConstraintError, 'A negated sort is not ' + 
            'implemented.'
        end
        unless enum.respond_to? :to_int_var_array
          raise TypeError, "Expected int var array but got #{enum.class}."
        end
        
        @params.update(:rhs => enum)
        @model.add_constraint SortConstraint.new(@model, 
          @params.update(Gecode::Constraints::Util.decode_options(options)))
      end
      alias_comparison_methods
    end
    
    # Describes a sort constraint.
    class SortConstraint < Gecode::Constraints::Constraint
      def post
        params = @params.values_at(:lhs, :rhs, :indices, :strength).map do |param| 
          if param.respond_to? :to_int_var_array
            param.to_int_var_array
          else
            param
          end
        end.delete_if{ |param| param.nil? }
        Gecode::Raw::sortedness(@model.active_space, *params)
      end
    end
  end
end