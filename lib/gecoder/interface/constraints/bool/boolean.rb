module Gecode
  class FreeBoolVar
    def |(var)
      Constraints::Bool::ExpressionNode.new(self, @model) | var
    end
    
    def &(var)
      Constraints::Bool::ExpressionNode.new(self, @model) & var
    end
    
    def ^(var)
      Constraints::Bool::ExpressionNode.new(self, @model) ^ var
    end
    
    def implies(var)
      Constraints::Bool::ExpressionNode.new(self, @model).implies var
    end
  end
  
  # A module that gathers the classes and modules used in boolean constraints.
  module Constraints::Bool
    # Describes a boolean expression (following after must*).
    class Expression
      def ==(expression, options = {})
        @params.update Gecode::Constraints::Util.decode_options(options)
        @model.add_constraint BooleanConstraint.new(@model, 
          @params.update(:rhs => expression))
      end
      alias_comparison_methods
      
      # Constrains the boolean expression to imply the specified expression.
      def imply(expression, options = {})
        @params.update Gecode::Constraints::Util.decode_options(options)
        @params.update(:lhs => @params[:lhs].implies(expression), :rhs => true)
        @model.add_constraint BooleanConstraint.new(@model, @params)
      end
      
      # Constrains the boolean expression to be true.
      def true
        @params.update Gecode::Constraints::Util.decode_options({})
        @model.add_constraint BooleanConstraint.new(@model, 
          @params.update(:rhs => true))
      end
      
      # Constrains the boolean expression to be false.
      def false
        @params[:negate] = !@params[:negate]
        self.true
      end
    end
    
    # Describes a boolean constraint.
    class BooleanConstraint < Gecode::Constraints::ReifiableConstraint
      def post
        lhs, rhs, negate, strength, reif_var = @params.values_at(:lhs, :rhs, 
          :negate, :strength, :reif)
        space = (lhs.model || rhs.model).active_space
        
        # TODO: It should be possible to reduce the number of necessary 
        # variables and constraints a bit by altering the way that the top node
        # is posted, using its constraint for reification etc when possible. 
        
        if rhs.respond_to? :bind
          if reif_var.nil?
            Gecode::Raw::bool_eqv(space, lhs.bind, rhs.bind, !negate, strength)
          else
            if negate
              Gecode::Raw::bool_xor(space, lhs.bind, rhs.bind, reif_var.bind, 
                strength)
            else
              Gecode::Raw::bool_eqv(space, lhs.bind, rhs.bind, reif_var.bind, 
                strength)
            end
          end
        else
          should_hold = !negate & rhs
          if reif_var.nil?
            Gecode::Raw::MiniModel::BoolExpr.new(lhs.bind).post(space, 
              should_hold)
          else
            Gecode::Raw::bool_eqv(space, lhs.bind, reif_var.bind, should_hold, 
              strength)
          end
        end
      end
    end
  
    # A module containing the methods for the basic boolean operations. Depends
    # on that the class mixing it in defined #model.
    module OperationMethods
      include Gecode::Constraints::LeftHandSideMethods
      
      private
    
      # Maps the names of the methods to the corresponding bool constraint in 
      # Gecode.
      OPERATION_TYPES = {
        :|        => :bool_or,
        :&        => :bool_and,
        :^        => :bool_xor,
        :implies  => :bool_imp
      }
      
      public
      
      OPERATION_TYPES.each_pair do |name, operation|
        module_eval <<-"end_code"
          def #{name}(expression)
            unless expression.kind_of? ExpressionTree
              expression = ExpressionNode.new(expression)
            end
            ExpressionTree.new(self, expression) do |model, var1, var2|
              new_var = model.bool_var
              Gecode::Raw::#{operation}(model.active_space, var1.bind, var2.bind,
                new_var.bind, Gecode::Raw::ICL_DEF)
              new_var
            end
          end
        end_code
      end
      
      private
      
      # Produces an expression for the lhs module.
      def expression(params)
        params.update(:lhs => self)
        Gecode::Constraints::Bool::Expression.new(model, params)
      end
    end
  
    # Describes a binary tree of expression nodes which together form a boolean 
    # expression.
    class ExpressionTree
      include OperationMethods
    
      # Constructs a new expression with the specified nodes. The proc should 
      # take a model followed by two variables and return a new variable.
      def initialize(left_tree, right_tree, &block)
        @left = left_tree
        @right = right_tree
        @bind_proc = block
      end
      
      # Returns a bound boolean variable representing the expression. 
      def bind
        @bind_proc.call(model, @left, @right).bind
      end
      
      # Fetches the space that the expression's variables is in.
      def model
        @left.model || @right.model
      end
    end
  
    # Describes a single node in a boolean expression.
    class ExpressionNode
      include OperationMethods
    
      attr :model
    
      def initialize(value, model = nil)
        @value = value
        @model = model
      end
      
      # Returns a bound boolean variable representing the expression. 
      def bind
        @value.bind
      end
    end
  end
end