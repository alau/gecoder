module Gecode
  class FreeIntVar
    include Gecode::Constraints::LeftHandSideMethods
    
    private
    
    # Produces an expression for the lhs module.
    def expression(params)
      params.update(:lhs => self)
      Constraints::Int::Expression.new(@model, params)
    end
  end
  
  # A module containing constraints that have int variables as left hand side
  # (but not enumerations).
  module Constraints::Int
    class Expression < Gecode::Constraints::Expression
    end
    
    # A composite expression which is an int expression with a left hand side 
    # resulting from a previous constraint.
    class CompositeExpression < Gecode::Constraints::Expression
      # The block given should take three parameters. The first is the variable 
      # that should be the left hand side, if it's nil then a new one should be
      # created. The second is the propagation strength. The third is the (free)
      # boolean variable to use for reification (possibly nil, i.e. none). The 
      # block should return the variable used as left hand side.
      def initialize(model, params, &block)
        super(model, params)
        @proc = block
      end
      
      # Delegate to Gecode::Constraints::Int::Expression when we get something 
      # that we can't handle.
      def method_missing(name, *args)
        if Gecode::Constraints::Int::Expression.instance_methods.include? name.to_s
          options = {}
          if args.size >= 2 and args[1].kind_of? Hash
            options = args[1]
          end
          @params.update Gecode::Constraints::Util.decode_options(options.clone)
          @params[:lhs] = @proc.call(nil, @params)
          Gecode::Constraints::Int::Expression.new(@model, @params).send(
            name, *args)
        end
      end
      
      def ==(expression, options = {})
        if !@params[:negate] and options[:reify].nil? and 
            expression.kind_of? Gecode::FreeIntVar
          # We don't need any additional constraints.
          @params.update Gecode::Constraints::Util.decode_options(options)
          @proc.call(expression, @params)
        else
          method_missing(:==, expression, options)
        end
      end
      alias_comparison_methods
    end
    
    # Describes a stub that produces an int variable, which can then be used with 
    # the normal int variable constraints. An example would be the element
    # constraint.
    #
    #   int_enum[int_var].must > rhs
    #
    # The int_enum[int_var] part produces an int variable which the constraint
    # ".must > rhs" is then applied to. In the above case two constraints (and
    # one temporary variable) are required, but in the case of equality only 
    # one constraint is required.
    class CompositeStub < Gecode::Constraints::ExpressionStub
      include Gecode::Constraints::LeftHandSideMethods
      
      private
      
      # Constrains the result of the stub to be equal to the specified variable
      # with the specified parameters. If the variable given is nil then a new
      # variable should be created for the purpose and returned. This is an 
      # abstract method and should be overridden by all sub-classes.
      def constrain_equal(variable, params)
        raise NoMethodError, 'Abstract method has not been implemented.'
      end
      
      # Produces an expression with position for the lhs module.
      def expression(params)
        @params.update params
        CompositeExpression.new(@model, @params) do |var, params|
          constrain_equal(var, params)
        end
      end
    end
  end
end

require 'gecoder/interface/constraints/int/linear'
require 'gecoder/interface/constraints/int/domain'
require 'gecoder/interface/constraints/int/arithmetic'
