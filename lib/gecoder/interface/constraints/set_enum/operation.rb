module Gecode::SetEnumMethods
  Gecode::Constraints::Util::SET_OPERATION_TYPES.each_pair do |name, type|
    next if type == Gecode::Raw::SOT_MINUS # Does not support this constraint?
    
    module_eval <<-"end_code"
      # Starts a constraint on the #{name} of the sets.
      def #{name}
        params = {:lhs => self, :operation => #{type}}
        Gecode::Constraints::SetEnum::Operation::ExpressionStub.new(
          @model, params)
      end
    end_code
  end
end

# A module that gathers the classes and modules used by operation constaints.
module Gecode::Constraints::SetEnum::Operation #:nodoc:
  # Describes a CompositeStub for the enumeration operation constraint, which 
  # constrains the result of applying an operation between all set variables in 
  # a set enumeration. 
  # 
  # The supported operations are:
  # * union
  # * disjoint_union
  # * intersection
  # * minus
  # 
  # == Example
  # 
  #   # The union of all set variables in +sets+ must be subset of 1..17.
  #   sets.union.must_be.subset_of 1..17
  #   
  #   # The intersection of all set variables must equal [1,3,5].
  #   sets.intersection.must == [1,3,5]
  #   
  #   # The union of all set variable must be a subset of the set variable
  #   # +universe+.
  #   sets.union.must_be.subset_of universe
  #   
  #   # The same as above, but reified with the boolean variable 
  #   # +is_within_universe+. 
  #   sets.union.must_be.subset_of(universe, :reify => is_within_universe)
  class ExpressionStub < Gecode::Constraints::Set::CompositeStub
    def constrain_equal(variable, params, constrain)
      enum, operation = @params.values_at(:lhs, :operation)
    
      if constrain
        if operation == Gecode::Raw::SOT_INTER or 
            operation == Gecode::Raw::SOT_MINUS
          variable.must_be.subset_of enum.first.upper_bound
        else
          variable.must_be.subset_of enum.upper_bound_range
        end
      end
      
      Gecode::Raw::rel(@model.active_space, operation, enum.to_set_var_array,
        variable.bind)
    end
  end
end