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
  
  # A module that gathers the classes and modules used by boolean enumeration 
  # constraints.
  module Constraints::BoolEnum
    # Describes a CompositeStub for the conjunction constraint, which constrain
    # the conjunction of all boolean variables in an enumeration.
    # 
    # == Example
    # 
    #   # The conjunction of all variables in +bool_enum+ must be true. I.e. all
    #   # boolean variables must take the value true.
    #   bool_enum.conjunction.must_be.true
    #   
    #   # The conjunction of all variables in +bool_enum+ must equal b1.
    #   bool_enum.conjunction.must ==  b1
    #   
    #   # The conjunction of all variables in +bool_enum+ must not equal b1 and 
    #   # b2. It's reified it with +bool+ and selects the strength +domain+.
    #   bool_enum.conjunction.must_not.equal(b1 & b2, :reify => bool, 
    #     :strength => :domain)
    class ConjunctionStub < Gecode::Constraints::Bool::CompositeStub
      def constrain_equal(variable, params, constrain)
        enum = @params[:lhs]
        
        @model.add_interaction do
          if variable.respond_to? :bind
            bound = variable.bind
          else
            bound = variable ? 1 : 0
          end
          Gecode::Raw::rel(@model.active_space, Gecode::Raw::BOT_AND,
            enum.to_bool_var_array, bound, *propagation_options)
        end
        return variable
      end
    end
    
    # Describes a CompositeStub for the disjunction constraint, which constrain
    # the disjunction of all boolean variables in an enumeration.
    # 
    # == Example
    # 
    #   # The disjunction of all variables in +bool_enum+ must be true. I.e. at
    #   # least one of the boolean variables must take the value true.
    #   bool_enum.disjunction.must_be.true
    #   
    #   # The disjunction of all variables in +bool_enum+ must equal b1.
    #   bool_enum.conjunction.must ==  b1
    #   
    #   # The disjunction of all variables in +bool_enum+ must not equal b1 and 
    #   # b2. It's reified it with +bool+ and selects the strength +domain+.
    #   bool_enum.disjunction.must_not.equal(b1 & b2, :reify => bool, 
    #     :strength => :domain)
    class DisjunctionStub < Gecode::Constraints::Bool::CompositeStub
      def constrain_equal(variable, params, constrain)
        enum = @params[:lhs]
        
        @model.add_interaction do
          if variable.respond_to? :bind
            bound = variable.bind
          else
            bound = variable ? 1 : 0
          end
          Gecode::Raw::rel(@model.active_space, Gecode::Raw::BOT_OR,
            enum.to_bool_var_array, bound, *propagation_options)
        end
      end
    end
  end
end