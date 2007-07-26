module Gecode::SetEnumMethods
  # This adds the adder for the methods in the modules including it. The 
  # reason for doing it so indirect is that the first #[] won't be defined 
  # before the module that this is mixed into is mixed into an enum.
  def self.included(mod)
    mod.module_eval do
      # Now we enter the module that the module possibly defining #[] 
      # is mixed into.
      if instance_methods.include?('[]') and 
          not instance_methods.include?('pre_selection_access')
        alias_method :pre_selection_access, :[]
      end
    
      def [](*vars)
        # Hook in an element constraint if a variable is used for array 
        # access.
        if vars.first.kind_of? Gecode::FreeIntVar
          params = {:lhs => self, :index => vars.first}
          Gecode::Constraints::SetEnum::Selection::SelectExpressionStub.new(
            @model, params)
        elsif vars.first.kind_of? Gecode::FreeSetVar
          params = {:lhs => self, :indices => vars.first}
          Gecode::Constraints::SetEnum::Selection::SetAccessStub.new(
            @model, params)
        else
          pre_selection_access(*vars) if respond_to? :pre_selection_access
        end
      end
    end
  end
end

# A module that gathers the classes and modules used by selection constraints.
module Gecode::Constraints::SetEnum::Selection
  # Describes an expression stub started with a set var enum following with an 
  # array access using an integer variable.
  class SelectExpressionStub < Gecode::Constraints::Set::CompositeStub
    def constrain_equal(variable, params, constrain)
      enum, index = @params.values_at(:lhs, :index)
      if constrain
        variable.must_be.subset_of enum.upper_bound_range
      end

      Gecode::Raw::selectSet(@model.active_space, enum.to_set_var_array, 
        index.bind, variable.bind)
    end
  end
  
  # Describes an expression stub started with a set var enum followed with an
  # array access using a set variable.
  class SetAccessStub < Gecode::Constraints::ExpressionStub
    include Gecode::Constraints::LeftHandSideMethods
    
    # Starts a union selection constraint on the selected sets.
    def union
      UnionExpressionStub.new(@model, @params)
    end
    
    # Starts a intersection selection constraint on the selected sets. The 
    # option :with may optionally be specified, in which case the value should
    # be an enumeration of the elements in the universe.
    def intersection(options = {})
      unless options.empty? 
        unless options.size == 1 and options.has_key?(:with)
          raise ArgumentError, "Expected option key :with, got #{options.keys}."
        else
          universe = options[:with]
          unless universe.kind_of?(Enumerable) and 
              universe.all?{ |element| element.kind_of? Fixnum }
            raise TypeError, "Expected the universe to be specified as " + 
              "an enumeration of fixnum, got #{universe.class}."
          end
          @params.update(:universe => universe)
        end
      end
      
      IntersectionExpressionStub.new(@model, @params)
    end
    
    private
    
    # Produces an expression with position for the lhs module.
    def expression(params)
      SetAccessExpression.new(@model, @params.update(params))
    end
  end
  
  # Describes an expression stub started with a set var enum following with an 
  # array access using a set variable followed by #union.
  class UnionExpressionStub < Gecode::Constraints::Set::CompositeStub
    def constrain_equal(variable, params, constrain)
      enum, indices = @params.values_at(:lhs, :indices)
      if constrain
        variable.must_be.subset_of enum.upper_bound_range
      end
      
      Gecode::Raw::selectUnion(@model.active_space, enum.to_set_var_array,
        indices.bind, variable.bind)
    end
  end
  
  # Describes an expression stub started with a set var enum following with an 
  # array access using a set variable followed by #intersection.
  class IntersectionExpressionStub < Gecode::Constraints::Set::CompositeStub
    def constrain_equal(variable, params, constrain)
      enum, indices, universe = @params.values_at(:lhs, :indices, :universe)
      # We can't do any useful constraining here since the empty intersection
      # is the universe.
      
      if universe.nil?
        Gecode::Raw::selectInter(@model.active_space, enum.to_set_var_array,
          indices.bind, variable.bind)
      else
        Gecode::Raw::selectInterIn(@model.active_space, enum.to_set_var_array,
          indices.bind, variable.bind, 
          Gecode::Constraints::Util.constant_set_to_int_set(universe))
      end
    end
  end
  
  # Describes an expression that starts with an set variable enum followed with
  # an array access using a set variable followed by some form of must.
  class SetAccessExpression < Gecode::Constraints::Set::Expression
    # Constrains the selected sets to be disjoint.
    def disjoint
      if @params[:negate]
        raise Gecode::MissingConstraintError, 'A negated set selection ' + 
          'disjoint is not implemented.'
      end
      
      @model.add_constraint DisjointConstraint.new(@model, @params)
    end
  end
  
  # Describes a disjoint constraint produced by sets[set].must_be.disjoint .
  class DisjointConstraint < Gecode::Constraints::Constraint
    def post
      enum, indices = @params.values_at(:lhs, :indices)
      Gecode::Raw.selectDisjoint(@model.active_space, enum.to_set_var_array,
        indices.bind)
    end
  end
end
