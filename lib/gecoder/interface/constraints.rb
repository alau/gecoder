module Gecode
  # An error signaling that the constraint specified is missing (e.g. one tried
  # to negate a constraint, but no negated form is implemented).
  class MissingConstraintError < StandardError
  end
  
  # A module containing all the constraints.
  module Constraints
    # A module that provides some utility-methods for decoding options given to
    # constraints.
    module OptionUtil
      private
      
      # Maps the name used in options to the value used in Gecode for 
      # propagation strengths.
      PROPAGATION_STRENGTHS = {
        :default  => Gecode::Raw::ICL_DEF,
        :value    => Gecode::Raw::ICL_VAL,
        :bounds   => Gecode::Raw::ICL_BND,
        :domain   => Gecode::Raw::ICL_DOM
      }
      
      public
      
      module_function
      
      # Decodes the common options to constraints: strength and reification. 
      # Returns two values, the first is the strength that should be used for
      # the constraint and the second is the (bound) boolean variable that 
      # should be used for reification, or nil if no such variable exist. The
      # decoded options are removed from the hash (so in general the hash will
      # be consumed in the process).
      # 
      # Raises ArgumentError if an unrecognized option is found in the specified
      # hash. Or if an unrecognized strength is given. Raises TypeError if the
      # reification variable is not a boolean variable.
      def decode_options(options)
        # Propagation strength.
        strength = options.delete(:strength) || :default
        unless PROPAGATION_STRENGTHS.include? strength
          raise ArgumentError, "Unrecognized propagation strength #{strength}."
        end
        
        # Reification.
        reif_var = options.delete(:reify)
        unless reif_var.nil? or reif_var.kind_of? FreeBoolVar
          raise TypeError, 'Only boolean variables may be used for reification.'
        end
        reif_var = reif_var.bind unless reif_var.nil?
        
        # Check for unrecognized options.
        unless options.empty?
          raise ArgumentError, 'Unrecognized constraint option: ' + 
            options.keys.first.to_s
        end
        
        return PROPAGATION_STRENGTHS[strength], reif_var
      end
    end
  end
end

require 'gecoder/interface/constraints/int_var_constraints'
require 'gecoder/interface/constraints/int_enum_constraints'
