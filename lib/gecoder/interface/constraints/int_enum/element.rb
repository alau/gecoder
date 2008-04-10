# A module that gathers the classes and modules used by element constraints.
module Gecode::Constraints::IntEnum::Element #:nodoc:
  # Describes a CompositeStub for the element constraint, which places a 
  # constraint on a variable at the specified position in an enumeration of 
  # integer variables. It's basically the array access of constraint 
  # programming.
  # 
  # == Example
  # 
  #   # The variable at the +x+:th position in +int_enum+ must be larger than
  #   # +y+.
  #   int_enum[x].must > y
  # 
  #   # The price of +selected_item+ as described by +prices+ must not be 
  #   # larger than 100.
  #   prices = wrap_enum([500, 24, 4711, 412, 24])
  #   prices[selected_item].must_not > 100
  #   
  #   # Reify the constraint that the +x+:th variable in +int_enum+ must be in 
  #   # range 7..17 with the boolean variable +bool+ and select strength 
  #   # +domain+.  
  # 
  #   int_enum[x].must_be.in(7..17, :reify => bool, :strength => :domain)
  class ExpressionStub < Gecode::Constraints::Int::CompositeStub
    def constrain_equal(variable, params, constrain)
      enum, position = @params.values_at(:lhs, :position)
      if constrain
        variable.must_be.in enum.domain_range
      end
      
      # The enum can be a constant array.
      enum = enum.to_int_var_array if enum.respond_to? :to_int_var_array
      Gecode::Raw::element(@model.active_space, enum, 
        position.bind, variable.bind, *propagation_options)
    end
  end
  
  # Methods needed to add support for element constraints to enums.
  module AdditionalEnumMethods #:nodoc:
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
