module Gecode::SetEnumMethods
  # This adds the adder for the methods in the modules including it. The 
  # reason for doing it so indirect is that the first #[] won't be defined 
  # before the module that this is mixed into is mixed into an enum.
  def self.included(mod) #:nodoc:
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
module Gecode::Constraints::SetEnum::Selection #:nodoc:
  # Describes an expression stub started with a set var enum followed with an
  # array access using a set variable.
  class SetAccessStub < Gecode::Constraints::ExpressionStub #:nodoc:
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
  
  # Describes an expression that starts with an set variable enum followed with
  # an array access using a set variable followed by some form of must.
  class SetAccessExpression < Gecode::Constraints::Set::Expression #:nodoc:
    # Constrains the selected sets to be disjoint.
    def disjoint
      if @params[:negate]
        raise Gecode::MissingConstraintError, 'A negated set selection ' + 
          'disjoint is not implemented.'
      end
      
      @model.add_constraint DisjointConstraint.new(@model, @params)
    end
  end

  # Describes a CompositeStub for the set select constraint, which constrains 
  # the set in a position specified by an integer variable in an enumeration of 
  # set variable.
  # 
  # == Examples
  # 
  #   # The set at the position described by the integer variable 
  #   # +singleton_zero_position+ in the enumeration +sets+ of set variables 
  #   # must equal [0].
  #   sets[singleton_zero_position].must == 0
  #   
  #   # The set at the position described by the integer variable +position+ in 
  #   # the enumeration +sets+ of set variables must be a subset of +set+.
  #   sets[position].must_be.subset_of set
  #   
  #   # The same as above, but reified with the boolean variable +bool+.
  #   sets[position].must_be.subset_of(set, :reify => bool)
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
  
  # Describes a CompositeStub for the set union selection constraint, 
  # which constrains the union of sets located at the positions 
  # specified by a set variable in an enumeration of set variables.
  # 
  # == Examples
  # 
  #   # The sets in the enumeration set variable +sets+ located at the positions
  #   # described by the set variable +selected_sets+ must have a union that's
  #   # a superset of [0,4,17]. 
  #   sets[selected_sets].union.must_be.superset_of [0,4,17]
  #   
  #   # The sets in the enumeration set variable +sets+ located at the positions
  #   # described by the set variable +selected_sets+ must have a union that's
  #   # disjoint with the set variable +set+.
  #   sets[selected_sets].union.must_be.disjoint_with set
  #   
  #   # The same as above but reified with the boolean variable 
  #   # +union_is_disjoint+.
  #   sets[selected_sets].union.must_be.disjoint_with(set, 
  #     :reify => union_is_disjoin)
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
  
  # Describes a CompositeStub for the set intersection selection constraint, 
  # which constrains the intersection of sets located at the positions 
  # specified by a set variable in an enumeration of set variables.
  # 
  # Optionally a universe may also be specified.
  # 
  # == Examples
  # 
  #   # The sets in the enumeration set variable +sets+ located at the positions
  #   # described by the set variable +selected_sets+ must have an intersection 
  #   # that's a superset of [0,4,17]. 
  #   sets[selected_sets].intersection.must_be.superset_of [0,4,17]
  #   
  #   # The sets in the enumeration set variable +sets+ located at the positions
  #   # described by the set variable +selected_sets+ must have an intersection
  #   # that's disjoint with the set variable +set+.
  #   sets[selected_sets].intersection.must_be.disjoint_with set
  #   
  #   # The sets in the enumeration set variable +sets+ located at the positions
  #   # described by the set variable +selected_sets+ must have an intersection
  #   # that's disjoint with the set variable +set+ inside the universe 0..17.
  #   sets[selected_sets].intersection(:with => 0..17).must_be.disjoint_with set
  #   
  #   # The sets in the enumeration set variable +sets+ located at the positions
  #   # described by the set variable +selected_sets+ must have an intersection
  #   # that's disjoint with the set variable +set+ inside the universe 
  #   # described by the set variable +universe+.
  #   sets[selected_sets].intersection(:with => universe).must_be.disjoint_with set
  #   
  #   
  #   # The same as above but reified with the boolean variable 
  #   # +intersection_is_disjoint+.
  #   sets[selected_sets].intersection(:with => universe).must_be.disjoint_with(
  #     set, :reifty => intersection_is_disjoin)
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
  
  # Describes a disjoint constraint, which constrains all set variable is an
  # enumeration, at the position specified by a set variable, to be disjoint.
  # 
  # Does not support negation nor reification.
  # 
  # == Examples
  # 
  #   # The set variable located in the enumeration +sets+ at positions 
  #   # described by +disjoint_set_positions+ must be disjoint.
  #   sets[disjoint_set_positions].must_be.disjoint 
  class DisjointConstraint < Gecode::Constraints::Constraint
    def post
      enum, indices = @params.values_at(:lhs, :indices)
      Gecode::Raw.selectDisjoint(@model.active_space, enum.to_set_var_array,
        indices.bind)
    end
  end
end
