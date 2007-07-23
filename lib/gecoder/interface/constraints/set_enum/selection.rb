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
          return Gecode::Constraints::SetEnum::Selection::SelectExpressionStub.new(
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
  # Describes an expression stub started with an set var enum following with an 
  # array access using an integer variables .
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
end
