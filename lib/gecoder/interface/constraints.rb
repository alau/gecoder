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
    module LeftHandSideMethods #:nodoc:
      # Specifies that a constraint must hold for the keft hand side.
      def must
        expression update_params(:negate => false)
      end
      alias_method :must_be, :must
      
      # Specifies that the negation of a constraint must hold for the left hand 
      # side.
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
    
    # A module that provides some utility-methods for constraints.
    module Util #:nodoc:
      # Maps the name used in options to the value used in Gecode for 
      # propagation strengths.
      PROPAGATION_STRENGTHS = {
        :default  => Gecode::Raw::ICL_DEF,
        :value    => Gecode::Raw::ICL_VAL,
        :bounds   => Gecode::Raw::ICL_BND,
        :domain   => Gecode::Raw::ICL_DOM
      }
      
      # Maps the name used in options to the value used in Gecode for 
      # propagation kinds.
      PROPAGATION_KINDS = {
        :default  => Gecode::Raw::PK_DEF,
        :speed    => Gecode::Raw::PK_SPEED,
        :memory   => Gecode::Raw::PK_MEMORY,
      } 
      
      # Maps the names of the methods to the corresponding integer relation 
      # type in Gecode.
      RELATION_TYPES = { 
        :== => Gecode::Raw::IRT_EQ,
        :<= => Gecode::Raw::IRT_LQ,
        :<  => Gecode::Raw::IRT_LE,
        :>= => Gecode::Raw::IRT_GQ,
        :>  => Gecode::Raw::IRT_GR
      }
      # The same as above, but negated.
      NEGATED_RELATION_TYPES = {
        :== => Gecode::Raw::IRT_NQ,
        :<= => Gecode::Raw::IRT_GR,
        :<  => Gecode::Raw::IRT_GQ,
        :>= => Gecode::Raw::IRT_LE,
        :>  => Gecode::Raw::IRT_LQ
      }
      
      # Maps the names of the methods to the corresponding set relation type in 
      # Gecode.
      SET_RELATION_TYPES = { 
        :==         => Gecode::Raw::SRT_EQ,
        :superset   => Gecode::Raw::SRT_SUP,
        :subset     => Gecode::Raw::SRT_SUB,
        :disjoint   => Gecode::Raw::SRT_DISJ,
        :complement => Gecode::Raw::SRT_CMPL
      }
      # The same as above, but negated.
      NEGATED_SET_RELATION_TYPES = {
        :== => Gecode::Raw::SRT_NQ
      }
      # Maps the names of the methods to the corresponding set operation type in 
      # Gecode.
      SET_OPERATION_TYPES = { 
        :union          => Gecode::Raw::SOT_UNION,
        :disjoint_union => Gecode::Raw::SOT_DUNION,
        :intersection   => Gecode::Raw::SOT_INTER,
        :minus          => Gecode::Raw::SOT_MINUS
      }
      
      # Various method aliases for comparison methods. Maps the original 
      # (symbol) name to an array of aliases.
      COMPARISON_ALIASES = { 
        :== => [:equal, :equal_to],
        :>  => [:greater, :greater_than],
        :>= => [:greater_or_equal, :greater_than_or_equal_to],
        :<  => [:less, :less_than],
        :<= => [:less_or_equal, :less_than_or_equal_to]
      }
      SET_ALIASES = { 
        :==         => [:equal, :equal_to],
        :superset   => [:superset_of],
        :subset     => [:subset_of],
        :disjoint   => [:disjoint_with],
        :complement => [:complement_of]
      }
      
      module_function
      
      # Decodes the common options to constraints: strength, kind and 
      # reification. Returns a hash with up to three values. :strength is the 
      # strength that should be used for the constraint, :kind is the 
      # propagation kind that should be used, and :reif is the (bound) boolean 
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
        
        # Propagation kind.
        kind = options.delete(:kind) || :default
        unless PROPAGATION_KINDS.include? kind
          raise ArgumentError, "Unrecognized propagation kind #{kind}."
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
        return {
          :strength => PROPAGATION_STRENGTHS[strength], 
          :kind => PROPAGATION_KINDS[kind],
          :reif => reif_var
        }
      end
      
      # Converts the different ways to specify constant sets in the interface
      # to the form that the set should be represented in Gecode (possibly 
      # multiple paramters. The different forms accepted are:
      # * Single instance of Fixnum (singleton set).
      # * Range (set containing all numbers in range), treated differently from
      #   other enumerations.
      # * Enumeration of integers (set contaning all numbers in set).
      def constant_set_to_params(constant_set)
        unless constant_set?(constant_set)
          raise TypeError, "Expected a constant set, got: #{constant_set}."
        end
      
        if constant_set.kind_of? Range
          return constant_set.first, constant_set.last
        elsif constant_set.kind_of? Fixnum
          return constant_set
        else
          constant_set = constant_set.to_a
          return Gecode::Raw::IntSet.new(constant_set, constant_set.size)
        end
      end
      
      # Converts the different ways to specify constant sets in the interface
      # to an instance of Gecode::Raw::IntSet. The different forms accepted are:
      # * Single instance of Fixnum (singleton set).
      # * Range (set containing all numbers in range), treated differently from
      #   other enumerations.
      # * Enumeration of integers (set contaning all numbers in set).
      def constant_set_to_int_set(constant_set)
        unless constant_set?(constant_set)
          raise TypeError, "Expected a constant set, got: #{constant_set}."
        end
        
        if constant_set.kind_of? Range
          return Gecode::Raw::IntSet.new(constant_set.first, constant_set.last)
        elsif constant_set.kind_of? Fixnum
          return Gecode::Raw::IntSet.new([constant_set], 1)
        else
          constant_set = constant_set.to_a
          return Gecode::Raw::IntSet.new(constant_set, constant_set.size)
        end
      end
      
      # Checks whether the specified expression is regarded as a constant set.
      # Returns true if it is, false otherwise.
      def constant_set?(expression)
        return (
           expression.kind_of?(Range) &&        # It's a range.
           expression.first.kind_of?(Fixnum) &&
           expression.last.kind_of?(Fixnum)) ||
          expression.kind_of?(Fixnum) ||        # It's a single fixnum.
          (expression.kind_of?(Enumerable) &&   # It's an enum of fixnums.
           expression.all?{ |e| e.kind_of? Fixnum })
      end
      
      # Extracts an array of the values selected for the standard propagation 
      # options (propagation strength and propagation kind) from the hash of
      # parameters given. The options are returned in the order that they are 
      # given when posting constraints to Gecode.      
      def extract_propagation_options(params)
        params.values_at(:strength, :kind)
      end
    end
    
    # A module that contains utility-methods for extensional constraints.
    module Util::Extensional #:nodoc:
      module_function
      
      # Checks that the specified enumeration is an enumeration containing 
      # one or more tuples of the specified size. It also allows the caller
      # to define additional tests by providing a block, which is given each
      # tuple. If a test fails then an appropriate error is raised.
      def perform_tuple_checks(tuples, expected_size, &additional_test)
        unless tuples.respond_to?(:each)
          raise TypeError, 'Expected an enumeration with tuples, got ' + 
            "#{tuples.class}."
        end
        
        if tuples.empty?
          raise ArgumentError, 'One or more tuples must be specified.'
        end
        
        tuples.each do |tuple|
          unless tuple.respond_to?(:each)
            raise TypeError, 'Expected an enumeration containing enumeraions, ' +
              "got #{tuple.class}."
          end
          
          unless tuple.size == expected_size
            raise ArgumentError, 'All tuples must be of the same size as the ' + 
              'number of variables in the array.'
          end
          
          yield tuple
        end
      end
    end
    
    # Describes a constraint expressions. An expression is produced by calling
    # some form of must on a left hand side. The expression waits for a right 
    # hand side so that it can post the corresponding constraint.
    class Expression #:nodoc:
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
      
      private
      
      # Provides commutivity for the constraint with the specified method name.
      # If the method with the specified method name is called with something 
      # that, when given to the block, evaluates to true, then the constraint
      # will be called on the right hand side with the left hand side as 
      # argument.
      #
      # The original constraint method is assumed to take two arguments: a 
      # right hand side and a hash of options.
      def self.provide_commutivity(constraint_name, &block)
        unique_id = constraint_name.to_sym.to_i
        pre_alias_method_name = 'pre_commutivity_' << unique_id.to_s
        if method_defined? constraint_name
          alias_method pre_alias_method_name, constraint_name
        end
        
        module_eval <<-end_code
          @@commutivity_check_#{unique_id} = block
          def #{constraint_name}(rhs, options = {})
            if @@commutivity_check_#{unique_id}.call(rhs, options)
              if @params[:negate]
                rhs.must_not.method(:#{constraint_name}).call(
                  @params[:lhs], options)
              else
                rhs.must.method(:#{constraint_name}).call(
                  @params[:lhs], options)
              end
            else
              if self.class.method_defined? :#{pre_alias_method_name}
                #{pre_alias_method_name}(rhs, options)
              else
                raise TypeError, \"Unexpected argument type \#{rhs.class}.\" 
              end
            end
          end
        end_code
      end
      
      # Creates aliases for any defined comparison methods.
      def self.alias_comparison_methods
        Gecode::Constraints::Util::COMPARISON_ALIASES.each_pair do |orig, aliases|
          if instance_methods.include?(orig.to_s)
            aliases.each do |name|
              alias_method(name, orig)
            end
          end
        end
      end
      
      # Creates aliases for any defined set methods.
      def self.alias_set_methods
        Gecode::Constraints::Util::SET_ALIASES.each_pair do |orig, aliases|
          if instance_methods.include?(orig.to_s)
            aliases.each do |name|
              alias_method(name, orig)
            end
          end
        end
      end
    end
    
    # A composite expression which is a expression with a left hand side 
    # resulting from a previous constraint.
    class CompositeExpression < Gecode::Constraints::Expression #:nodoc:
      # The expression class should be the class of the expression delegated to,
      # the variable class the kind of single variable used in the expression.
      # The new var proc should produce a new variable (of the appropriate type)
      # which has an unconstricted domain. The block given should take three 
      # parameters. The first is the variable that should be the left hand side.
      # The second is the hash of parameters. The third is a boolean, it it's 
      # true then the block should try to constrain the first variable's domain 
      # as much as possible. 
      def initialize(expression_class, variable_class, new_var_proc, model, 
          params, &block)
        super(model, params)
        @expression_class = expression_class
        @variable_class = variable_class
        @new_var_proc = new_var_proc
        @constrain_equal_proc = block
      end
      
      # Delegate to an instance of the expression class when we get something 
      # that we can't handle.
      def method_missing(name, *args)
        if @expression_class.instance_methods.include? name.to_s
          options = {}
          if args.size >= 2 and args[1].kind_of? Hash
            options = args[1]
          end
          
          # Link a variable to the composite constraint.
          @params.update Gecode::Constraints::Util.decode_options(options.clone)
          variable = @new_var_proc.call
          @model.add_interaction do
            @constrain_equal_proc.call(variable, @params, true)
          end
          
          # Perform the operation on the linked variable.
          int_var_params = @params.clone.update(:lhs => variable)
          @expression_class.new(@model, int_var_params).send(name, *args)
        else
          super
        end
      end
      
      def ==(expression, options = {})
        if !@params[:negate] and options[:reify].nil? and 
            expression.kind_of? @variable_class
          # We don't need any additional constraints.
          @params.update Gecode::Constraints::Util.decode_options(options)
          @model.add_interaction do
            @constrain_equal_proc.call(expression, @params, false)
          end
        else
          method_missing(:==, expression, options)
        end
      end
      alias_comparison_methods
    end
    
    # Describes a constraint expression that has yet to be completed. I.e. a
    # form of must has not yet been called, but some method has been called to
    # initiate the expression. An example is distinct with offsets:
    #
    #   enum.with_offsets(0..n).must_be.distinct
    # 
    # The call of with_offsets initiates the constraint as a stub, even though
    # must has not yet been called.
    class ExpressionStub #:nodoc:
      # Constructs a new expression with the specified parameters.
      def initialize(model, params)
        @model = model
        @params = params
      end
    end
    
    # Describes an expression stub which includes left hand side methods and
    # just sends models and parameters through a supplied block to construct the
    # resulting expression.
    class SimpleExpressionStub < ExpressionStub #:nodoc:
      include Gecode::Constraints::LeftHandSideMethods
    
      # The block provided is executed when the expression demanded by the left
      # hand side methods is to be constructed. The block should take two 
      # parameters: model and params (which have been updated with negate and
      # so on). The block should return an expression.
      def initialize(model, params, &block)
        super(model, params)
        @proc = block
      end
      
      private
      
      # Produces an expression with offsets for the lhs module.
      def expression(params)
        @params.update(params)
        @proc.call(@model, @params)
      end
    end
    
    # Describes a stub that produces a variable, which can then be used with 
    # that variable's normalconstraints. An example with int variables would be 
    # the element constraint.
    #
    #   int_enum[int_var].must > rhs
    #
    # The int_enum[int_var] part produces an int variable which the constraint
    # ".must > rhs" is then applied to. In the above case two constraints (and
    # one temporary variable) are required, but in the case of equality only 
    # one constraint is required.
    class CompositeStub < Gecode::Constraints::ExpressionStub #:nodoc:
      include Gecode::Constraints::LeftHandSideMethods
      
      # The composite expression class should be the class that the stub uses
      # when creating its expressions.
      def initialize(composite_expression_class, model, params)
        super(model, params)
        @composite_class = composite_expression_class
      end
      
      private
      
      # Constrains the result of the stub to be equal to the specified variable
      # with the specified parameters. If constrain is true then the variable's
      # domain should additionally be constrained as much as possible.
      def constrain_equal(variable, params, constrain)
        raise NoMethodError, 'Abstract method has not been implemented.'
      end
      
      # Produces an expression with position for the lhs module.
      def expression(params)
        @params.update params
        @composite_class.new(@model, @params) do |var, params, constrain|
          constrain_equal(var, params, constrain)
        end
      end
      
      # Gives an array of the values selected for the standard propagation 
      # options (propagation strength and propagation kind) in the order that
      # they are given when posting constraints to Gecode.
      def propagation_options
        Gecode::Constraints::Util::extract_propagation_options(@params)
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
      
      private
      
      # Gives an array of the values selected for the standard propagation 
      # options (propagation strength and propagation kind) in the order that
      # they are given when posting constraints to Gecode.
      def propagation_options
        Gecode::Constraints::Util::extract_propagation_options(@params)
      end
    end
  end
end

require 'gecoder/interface/constraints/reifiable_constraints'
require 'gecoder/interface/constraints/int_var_constraints'
require 'gecoder/interface/constraints/int_enum_constraints'
require 'gecoder/interface/constraints/bool_var_constraints'
require 'gecoder/interface/constraints/bool_enum_constraints'
require 'gecoder/interface/constraints/set_var_constraints'
require 'gecoder/interface/constraints/set_enum_constraints'
require 'gecoder/interface/constraints/extensional_regexp'
