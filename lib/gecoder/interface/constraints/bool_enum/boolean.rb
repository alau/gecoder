module Gecode
  module BoolEnumMethods
    # Produces an expression that can be handled as if it was a variable 
    # representing the conjunction of all boolean variables in the enumeration.
    def conjunction
      return Gecode::Constraints::BoolEnum::ConjunctionStub.new(
        @model, :lhs => self)
    end
    
    # Produces an expression that can be handled as if it was a variable 
    # representing the disjunction of all boolean variables in the enumeration.
    def disjunction
      return Gecode::Constraints::BoolEnum::DisjunctionStub.new(
        @model, :lhs => self)
    end
  end
  
  module Constraints::BoolEnum
    # Describes an expression stub started with a bool var enum following by 
    # #conjunction.
    class ConjunctionStub < Gecode::Constraints::Bool::CompositeStub
      def constrain_equal(variable, params, constrain)
        enum, strength = @params.values_at(:lhs, :strength)
        
        @model.add_interaction do
          if variable.respond_to? :bind
            bound = variable.bind
          else
            bound = variable
          end
          Gecode::Raw::bool_and(@model.active_space, enum.to_bool_var_array, 
            bound, strength)
        end
        return variable
      end
    end
    
    # Describes an expression stub started with a bool var enum following by 
    # #disjunction.
    class DisjunctionStub < Gecode::Constraints::Bool::CompositeStub
      def constrain_equal(variable, params, constrain)
        enum, strength = @params.values_at(:lhs, :strength)
        
        if variable.respond_to? :bind
          bound = variable.bind
        else
          bound = variable
        end
        Gecode::Raw::bool_or(@model.active_space, enum.to_bool_var_array, 
          bound, strength)
      end
    end
  end
end