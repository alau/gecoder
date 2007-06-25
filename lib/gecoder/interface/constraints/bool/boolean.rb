module Gecode
  class FreeBoolVar
    def |(var)
      Constraints::Bool::ExpressionNode.new(self, @model) | var
    end
    
    def &(var)
      Constraints::Bool::ExpressionNode.new(self, @model) & var
    end
  end
  
  module Constraints::Bool
    # Add some relation selection based on whether the expression is negated.
    alias_method :pre_bool_rel_initialize, :initialize
    class Expression
      def ==(expression)
        add_boolean_constraint(expression)
      end
      
      def true
        # Bind parameters.
        lhs = @params[:lhs]
        unless lhs.respond_to? :to_minimodel_lin_exp
          lhs = ExpressionNode.new(lhs, @model)
        end

        @model.add_constraint BooleanConstraint.new(@model, 
          @params.update(:expression => lhs.to_minimodel_lin_exp))
      end
      
      def false
        # Bind parameters.
        lhs = @params[:lhs]
        unless lhs.respond_to? :to_minimodel_lin_exp
          lhs = ExpressionNode.new(lhs, @model)
        end
        
        @params.update(:expression => Gecode::Raw::MiniModel::BoolExpr.new(
            lhs.to_minimodel_lin_exp, Gecode::Raw::MiniModel::BoolExpr::BT_NOT))
        @model.add_constraint BooleanConstraint.new(@model, @params)
      end
      
      private
      
      # Adds the boolean constraint corresponding to equivalence between the 
      # left and right hand sides.
      #
      # Raises TypeError if the element is of a type that doesn't allow a 
      # relation to be specified.
      def add_boolean_constraint(right_hand_side = nil)
        # Bind parameters.
        lhs = @params[:lhs]
        unless lhs.respond_to? :to_minimodel_lin_exp
          lhs = ExpressionNode.new(lhs, @model)
        end
        unless right_hand_side.respond_to? :to_minimodel_lin_exp
          right_hand_side = ExpressionNode.new(right_hand_side, @model)
        end
        
        expression = ExpressionTree.new(lhs, right_hand_side, 
          Gecode::Raw::MiniModel::BoolExpr::BT_EQV)
        @model.add_constraint BooleanConstraint.new(@model, 
          @params.update(:expression => expression.to_minimodel_lin_exp))
      end
    end
    
    # Describes a boolean constraint.
    class BooleanConstraint < Gecode::Constraints::Constraint
      def post
        @params[:expression].post(@model.active_space, !@params[:negate])
      end
    end
  
    # A module containing the methods for the basic boolean operations. Depends
    # on that the class mixing it in defined #model.
    module OperationMethods
      include Gecode::Constraints::LeftHandSideMethods
      
      private
    
      # Maps the names of the methods to the corresponding bool operation type
      # in Gecode.
      OPERATION_TYPES = {
        :|  => Gecode::Raw::MiniModel::BoolExpr::BT_OR,
        :&  => Gecode::Raw::MiniModel::BoolExpr::BT_AND
      }
      
      public
      
      OPERATION_TYPES.each_pair do |name, operation|
        module_eval <<-"end_code"
          def #{name}(expression)
            unless expression.kind_of? ExpressionTree
              expression = ExpressionNode.new(expression)
            end
            ExpressionTree.new(self, expression, #{operation})
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
    
      # Constructs a new expression with the specified variable
      def initialize(left_node, right_node, operation)
        @left = left_node
        @right = right_node
        @operation = operation
      end
      
      # Converts the boolean expression to an instance of 
      # Gecode::Raw::MiniModel::BoolExpr
      def to_minimodel_lin_exp
        Gecode::Raw::MiniModel::BoolExpr.new(@left.to_minimodel_lin_exp,
          @operation, @right.to_minimodel_lin_exp)
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
      
      # Converts the linear expression to an instance of 
      # Gecode::Raw::MiniModel::BoolExpr
      def to_minimodel_lin_exp
        expression = @value
        if expression.kind_of? Gecode::FreeBoolVar
          Gecode::Raw::MiniModel::BoolExpr.new(expression.bind)
        else
          expression
        end
      end
    end
  end
end