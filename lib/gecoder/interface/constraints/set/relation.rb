module Gecode
  class FreeSetVar
    # Starts a constraint on all the elements of the set.
    def elements
      params = {:lhs => self}
      Gecode::Constraints::SimpleExpressionStub.new(@model, params) do |m, ps|
        Gecode::Constraints::Set::Relation::ElementExpression.new(m, ps)
      end
    end
  end
end

module Gecode::Constraints::Set
  class Expression
    Gecode::Constraints::Util::SET_RELATION_TYPES.each_pair do |name, type|
      module_eval <<-"end_code"
        # Wrap previous relation methods providing support for relation 
        # constraints.
        alias_method 'pre_relation_#{type}_method'.to_sym, :#{name}
        
        # Creates a relation constraint using the specified expression.
        def #{name}(expression, options = {})
          if expression.kind_of? Gecode::FreeSetVar
            add_relation_constraint(:#{name}, expression, options)
          else
            # Send it on.
            pre_relation_#{type}_method(expression, options)
          end
        end
      end_code
    end
    alias_set_methods
    
    private
    
    # Adds a relation constraint for the specified relation name, set variable
    # and options.
    def add_relation_constraint(relation_name, set, options)
      @params[:rhs] = set
      @params[:relation] = relation_name
      @params.update Gecode::Constraints::Set::Util.decode_options(options)
      if relation_name == :==
        @model.add_constraint Relation::EqualityRelationConstraint.new(@model, 
          @params)
      else
        @model.add_constraint Relation::RelationConstraint.new(@model, @params)
      end
    end
  end
  
  # A module that gathers the classes and modules used in relation constraints.
  module Relation
    # Describes a relation constraint for equality.
    class EqualityRelationConstraint < Gecode::Constraints::ReifiableConstraint
      def post
        var, rhs, reif_var, negate = @params.values_at(:lhs, :rhs, :reif, 
          :negate)
        if negate
          rel_type = Gecode::Constraints::Util::NEGATED_SET_RELATION_TYPES[:==]
        else
          rel_type = Gecode::Constraints::Util::SET_RELATION_TYPES[:==]
        end
        
        (params = []) << var.bind
        params << rel_type
        params << rhs.bind
        params << reif_var.bind if reif_var.respond_to? :bind
        Gecode::Raw::rel(@model.active_space, *params)
      end
    end
  
    # Describes a relation constraint for the relations other than equality.
    class RelationConstraint < Gecode::Constraints::ReifiableConstraint
      def post
        var, rhs, reif_var, relation = @params.values_at(:lhs, :rhs, :reif, 
          :relation)
        
        (params = []) << var.bind
        params << Gecode::Constraints::Util::SET_RELATION_TYPES[relation]
        params << rhs.bind
        params << reif_var.bind if reif_var.respond_to? :bind
        Gecode::Raw::rel(@model.active_space, *params)
      end
      negate_using_reification
    end
    
    # Describes a relation constraint on the elements of a set.
    class ElementRelationConstraint < Gecode::Constraints::Constraint
      def post
        var, rhs, relation = @params.values_at(:lhs, :rhs, :relation)
        
        if @params[:negate]
          type = Gecode::Constraints::Util::NEGATED_RELATION_TYPES[relation]
        else
          type = Gecode::Constraints::Util::RELATION_TYPES[relation]
        end

        if rhs.kind_of? Fixnum
          # Use a proxy int variable to cover.
          rhs = @model.int_var(rhs)
        end
        Gecode::Raw::rel(@model.active_space, var.bind, type, rhs.bind)
      end
    end
    
    # Describes an expression which starts with set.element.must* .
    class ElementExpression < Gecode::Constraints::Expression
      Gecode::Constraints::Util::RELATION_TYPES.each_key do |name|
        module_eval <<-"end_code"
          # Creates an elements constraint using the specified expression, which
          # may be either a constant integer of variable.
          def #{name}(expression)
            unless expression.kind_of?(Fixnum) or 
                expression.kind_of?(Gecode::FreeIntVar)
              raise TypeError, "Invalid expression type \#{expression.class}."
            end
            @params.update(:rhs => expression, :relation => :#{name})
            @model.add_constraint ElementRelationConstraint.new(@model, @params)
          end
        end_code
      end
      alias_comparison_methods
    end
  end
end