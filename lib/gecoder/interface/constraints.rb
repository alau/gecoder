module Gecode
  # An error signaling that the constraint specified is missing (e.g. one tried
  # to negate a constraint, but no negated form is implemented).
  class MissingConstraintError < StandardError
  end
  
  # A module containing all the constraints.
  module Constraints
    # A module that should be mixed in to class of objects that should be usable
    # as left hand sides (i.e. the part before must*) when specifying 
    # constraints. Assumes that a method #expression is defined which produces
    # a new expression given the current constraint parameters.
    module LeftHandSideMethods
      # Specifies that a constraint must hold for the integer variable enum.
      def must
        expression update_params(:negate => false)
      end
      alias_method :must_be, :must
      
      # Specifies that the negation of a constraint must hold for the integer 
      # variable.
      def must_not
        expression update_params(:negate => true)
      end
      alias_method :must_not_be, :must_not
      
      private
      
      # Updates the parameters with the specified new parameters.
      def update_params(params_to_add)
        @constraint_params ||= {}
        @constraint_params.update(params_to_add)
      end
    end
    
    # Describes a constraint expressions. An expression is produced by calling
    # some form of must on a left hand side. The expression waits for a right 
    # hand side so that it can post the corresponding constraint.
    class Expression
      # Constructs a new expression with the specified parameters. The 
      # parameters shoud at least contain the keys :lhs, and :negate.
      #
      # Raises ArgumentError if any of those keys are missing.
      def initialize(model, params)
        unless params.has_key?(:lhs) and params.has_key?(:negate)
          raise ArgumentError, 'Expression requires at least :lhs, ' + 
            "and :negate as parameter keys, got #{params.keys.join(', ')}."
        end
        
        @model = model
        @params = params
      end
    end
    
    # Describes a constraint expression that has yet to be completed. I.e. a
    # form of must has not yet been called, but some method has been called to
    # initiate the expression. An example is distinct with offsets:
    #
    #   enum.with_offsets(0..n).must_be.distinct
    # 
    # The call of with_offsets initiates the constraint as a stub, even though
    # must has not yet been called.
    class ExpressionStub
      # Constructs a new expression with the specified parameters.
      def initialize(model, params)
        @model = model
        @params = params
      end
    end
    
    # Base class for all constraints.
    class Constraint
      # Creates a constraint with the specified parameters, bound to the 
      # specified model. 
      def initialize(model, params)
        @model = model
        @params = params.clone
      end
      
      # Posts the constraint, adding it to the model. This is an abstract 
      # method and should be overridden by all sub-classes.
      def post
        raise NoMethodError, 'Abstract method has not been implemented.'
      end
    end
  
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
      # Returns a hash with up to two values. :strength is the strength that 
      # should be used for the constraint and :reif is the (bound) boolean 
      # variable that should be used for reification. The decoded options are 
      # removed from the hash (so in general the hash will be consumed in the 
      # process).
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
        
        # Check for unrecognized options.
        unless options.empty?
          raise ArgumentError, 'Unrecognized constraint option: ' + 
            options.keys.first.to_s
        end
        return {:strength => PROPAGATION_STRENGTHS[strength], :reif => reif_var}
      end
    end
  end
end

require 'gecoder/interface/constraints/reifiable_constraints'
require 'gecoder/interface/constraints/int_var_constraints'
require 'gecoder/interface/constraints/int_enum_constraints'
require 'gecoder/interface/constraints/bool_var_constraints'
