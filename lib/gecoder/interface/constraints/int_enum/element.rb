# A module that gathers the classes and modules used by element constraints.
module Gecode::Constraints::IntEnum::Element 
  # Describes an expression stub started with an int var enum following with an 
  # array access using an integer variables .
  class ExpressionStub < Gecode::Constraints::ExpressionStub
    include Gecode::Constraints::LeftHandSideMethods
    
    private
    
    # Produces an expression with position for the lhs module.
    def expression(params)
      # We extract the integer and continue as if it had been specified as
      # left hand side. This might be elegant, but it could get away with 
      # fewer constraints at times (when only equality is used) and 
      # propagation strength can't be specified. 
      # TODO: cut down on the number of constraints when possible. See if 
      # there's some neat way of getting the above remarks. 
      
      params.update(@params)
      enum, position = params.values_at(:lhs, :position)
      tmp = @model.int_var(enum.domain_range)
      enum = enum.to_int_var_array if enum.respond_to? :to_int_var_array
      
      Gecode::Raw::element(@model.active_space, enum, 
        position.bind, tmp.bind, Gecode::Raw::ICL_DEF)
      Gecode::Constraints::Int::Expression.new(@model, 
        params.update(:lhs => tmp))
    end
  end
  
  # Methods needed to add support for element constraints to enums.
  module AdditionalEnumMethods
    # This adds the adder for the methods in the modules including it. The 
    # reason for doing it so indirect is that the first #[] won't be defined 
    # before the module that this is mixed into is mixed into an enum.
    def self.included(enum_mod)
      enum_mod.module_eval do
        # Now we enter the module AdditionalEnumMethods is mixed into.
        class << self
          alias_method :pre_element_included, :included
          def included(mod)
            mod.module_eval do
              # Now we enter the module that the module possibly defining #[] 
              # is mixed into.
              if instance_methods.include? '[]'
                alias_method :pre_element_access, :[]
              end
            
              def [](*vars)
                # Hook in an element constraint if a variable is used for array 
                # access.
                if vars.first.kind_of? Gecode::FreeIntVar
                  params = {:lhs => self, :position => vars.first}
                  return Gecode::Constraints::IntEnum::Element::ExpressionStub.new(
                    @model, params)
                else
                  pre_element_access(*vars) if respond_to? :pre_element_access
                end
              end
            end
            pre_element_included(mod)
          end
        end
      end
    end
  end
end

module Gecode::IntEnumMethods
  include Gecode::Constraints::IntEnum::Element::AdditionalEnumMethods
end

module Gecode::FixnumEnumMethods
  include Gecode::Constraints::IntEnum::Element::AdditionalEnumMethods
end
