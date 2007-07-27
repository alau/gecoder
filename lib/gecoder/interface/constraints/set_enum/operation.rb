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
module Gecode::Constraints::SetEnum::Operation
  # Describes a stub started with a set enumeration followed by a set operation.
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