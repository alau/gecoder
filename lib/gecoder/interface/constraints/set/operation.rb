module Gecode
  class FreeSetVar
    Gecode::Constraints::Util::SET_OPERATION_TYPES.each_pair do |name, type|
      module_eval <<-"end_code"
        # Starts a constraint on this set #{name} the specified set.
        def #{name}(operand)
          unless operand.kind_of?(Gecode::FreeSetVar) or 
              Gecode::Constraints::Util::constant_set?(operand)
            raise TypeError, 'Expected set variable or constant set as ' + 
              "operand, got \#{operand.class}."
          end

          params = {:lhs => self, :op2 => operand, :operation => #{type}}
          Gecode::Constraints::SimpleExpressionStub.new(@model, params) do |m, ps|
            Gecode::Constraints::Set::Operation::Expression.new(m, ps)
          end
        end
      end_code
    end
  end
  
  module FixnumEnumMethods
    Gecode::Constraints::Util::SET_OPERATION_TYPES.each_pair do |name, type|
      module_eval <<-"end_code"
        # Starts a constraint on this set union the specified set.
        def #{name}(operand)
          unless operand.kind_of?(Gecode::FreeSetVar) or 
              Gecode::Constraints::Util::constant_set?(operand)
            raise TypeError, 'Expected set variable or constant set as ' + 
              "operand, got \#{operand.class}."
          end

          params = {:lhs => self, :op2 => operand, :operation => #{type}}
          Gecode::Constraints::SimpleExpressionStub.new(@model, params) do |m, ps|
            Gecode::Constraints::Set::Operation::Expression.new(m, ps)
          end
        end
      end_code
    end
  end
end

module Gecode::Constraints::Set
  # A module that gathers the classes and modules used in operation constraints.
  module Operation #:nodoc:
    # An expression with a set operand and two operands followed by must.
    class Expression < Gecode::Constraints::Expression #:nodoc:
      Gecode::Constraints::Util::SET_RELATION_TYPES.each_pair do |name, type|
        module_eval <<-"end_code"
          # Creates an operation constraint using the specified expression.
          def #{name}(expression)
            if @params[:negate]
              # We do not allow negation.
              raise Gecode::MissingConstraintError, 'A negated set operation ' + 
                'constraint is not implemented.'
            end
            unless expression.kind_of?(Gecode::FreeSetVar) or 
                Gecode::Constraints::Util::constant_set?(expression)
              raise TypeError, 'Expected set variable or constant set, got ' + 
                "\#{expression.class}."
            end
            
            @params[:rhs] = expression
            @params[:relation] = #{type}
            unless @params.values_at(:lhs, :op2, :rhs).any?{ |element| 
                element.kind_of? Gecode::FreeSetVar}
              # At least one variable must be involved in the constraint.
              raise ArgumentError, 'At least one variable must be involved ' +
                'in the constraint, but all given were constants.'
            end
            
            @model.add_constraint OperationConstraint.new(@model, @params)
          end
        end_code
      end
      alias_set_methods
    end
    
    # Describes an operation constraint, which constrains the result of an
    # operation with two sets as operands. Either constant sets or set 
    # variables may be used for the result and operands, with the exception of
    # that all three may not be constant sets.
    # 
    # The typical form is
    #   set_operand_1.<operation>(set_operand_2).must.<relation>(result_set)
    # 
    # The following operations are supported:
    # 
    # * union
    # * disjoint_union
    # * intersection
    # * minus
    # 
    # The allowed relations are the same as for 
    # <tt>Set::Relation::RelationConstraint</tt>.
    # 
    # Neither reification nor negation is supported.
    # 
    # == Examples
    # 
    #   # +set_1+ union +set_2+ must equal +set_3+.
    #   set_1.union(set_2).must == set_3
    #   
    #   # +set_1+ intersection [3,5,6] must equal +set_3+.
    #   set_1.intersection([3,5,6]).must == set_3
    #   
    #   # [0,1,2] minus +set_2+ must be superset of +set_3+.
    #   wrap_enum([0,1,2]).minus(set_2).must_be.superset_of(set_3)
    #   
    #   # +set_1+ disjoint union with [0] must be subset of 0..17.
    #   set_1.disjoint_union(0).must_be.subset_of 0..17
    class OperationConstraint < Gecode::Constraints::Constraint
      def post
        op1, op2, operation, relation, rhs, negate = @params.values_at(:lhs, 
          :op2, :operation, :relation, :rhs, :negate)

        op1, op2, rhs = [op1, op2, rhs].map do |expression|
          # The expressions can either be set variables or constant sets, 
          # convert them appropriately.
          if expression.respond_to? :bind
            expression.bind
          else
            Gecode::Constraints::Util::constant_set_to_int_set(expression)
          end
        end

        Gecode::Raw::rel(@model.active_space, op1, operation, op2, relation, 
          rhs)
      end
    end
  end
end