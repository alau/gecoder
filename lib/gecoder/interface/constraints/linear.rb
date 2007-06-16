module Gecode
  class FreeIntVar
    # Creates a linear expression where the int variables are summed.
    def +(var)
      Gecode::LinearConstraintExpressionNode.new(self, active_space) + var
    end
    
    # Creates a linear expression where the int variable is multiplied with 
    # a constant integer.
    def *(int)
      Gecode::LinearConstraintExpressionNode.new(self, active_space) * int
    end
    
    # Creates a linear expression where the specified variable is subtracted 
    # from this one.
    def -(var)
      Gecode::LinearConstraintExpressionNode.new(self, active_space) - var
    end
  end
  
  module LinearConstraintHelper
    OPERATION_TYPES = [:+, :-, :*]
  
    # Define methods for the available operations.
    OPERATION_TYPES.each do |name|
      module_eval <<-"end_code"
        def #{name}(expression)
          unless expression.kind_of? Gecode::LinearConstraintExpressionTree
            expression = Gecode::LinearConstraintExpressionNode.new(expression)
          end
          Gecode::LinearConstraintExpressionTree.new(self, expression, :#{name})
        end
      end_code
    end
    
    # Specifies that a constraint must hold for the linear expression.
    def must
      Gecode::LinearConstraintExpression.new(self)
    end
    
    # Specifies that the negation of a constraint must hold for the linear
    # expression.
    def must_not
      Gecode::LinearConstraintExpression.new(self, true)
    end
  end
  
  # Describes a linear constraint that starts with a linear expression followed 
  # by must or must_not.
  class LinearConstraintExpressionTree
    include Gecode::LinearConstraintHelper
  
    # Constructs a new expression with the specified variable
    def initialize(left_node, right_node, operation)
      @left = left_node
      @right = right_node
      @operation = operation
    end
    
    # Converts the linear expression to an instance of 
    # Gecode::Raw::MiniModel::LinExpr
    def to_minimodel_lin_exp
      @left.to_minimodel_lin_exp.send(@operation, @right.to_minimodel_lin_exp)
    end
    
    # Fetches the space that the expression's variables is in.
    def space
      @left.space || @right.space
    end
  end
  
  # Describes a single node in a linear constrain expression.
  class LinearConstraintExpressionNode
    include Gecode::LinearConstraintHelper
  
    attr :space
  
    def initialize(value, space = nil)
      @value = value
      @space = space
    end
    
    # Converts the linear expression to an instance of 
    # Gecode::Raw::MiniModel::LinExpr
    def to_minimodel_lin_exp
      expression = @value
      if expression.kind_of? FreeIntVar
        # Minimodel requires that we do this first.
        expression = expression.bind * 1
      end
      expression
    end
  end
  
  # Describes a linear constraint expression that starts with a linear 
  # expression followed by must or must_not.
  class LinearConstraintExpression
    # TODO: this is awfully similar to IntVarConstrainExpression. There should
    # be some way to combine them.
  
    # Maps the names of the methods to the corresponding integer relation 
    # type in Gecode.
    RELATION_TYPES = { 
      :== => Gecode::Raw::IRT_EQ,
      :<= => Gecode::Raw::IRT_LQ,
      :<  => Gecode::Raw::IRT_LE,
      :>= => Gecode::Raw::IRT_GQ,
      :>  => Gecode::Raw::IRT_GR }
    # The same as above, but negated.
    NEGATED_RELATION_TYPES = {
      :== => Gecode::Raw::IRT_NQ,
      :<= => Gecode::Raw::IRT_GR,
      :<  => Gecode::Raw::IRT_GQ,
      :>= => Gecode::Raw::IRT_LE,
      :>  => Gecode::Raw::IRT_LQ
    }
    
    # Constructs the expression with the specified left hand side. The 
    # expression can optionally be negated.
    def initialize(left_hand_side, negate = false)
      @lhs = left_hand_side
      unless negate
        @method_relations = RELATION_TYPES
      else
        @method_relations = NEGATED_RELATION_TYPES
      end
    end
    
    RELATION_TYPES.each_key do |name|
      module_eval <<-"end_code"
        def #{name}(expression)
          post_relation_constraint(@method_relations[:#{name}], expression)
        end
      end_code
    end
    
    private
    
    # Places the relation constraint corresponding to the specified (integer)
    # relation type (as specified by Gecode) in relation to the specifed 
    # element.
    # 
    # Raises TypeError if the element is of a type that doesn't allow a relation
    # to be specified.
    def post_relation_constraint(relation_type, right_hand_side)
      if right_hand_side.respond_to? :to_minimodel_lin_exp
        right_hand_side = right_hand_side.to_minimodel_lin_exp
      elsif right_hand_side.kind_of? Gecode::FreeIntVar
        right_hand_side = right_hand_side.bind * 1
      elsif not right_hand_side.kind_of? Fixnum
        raise TypeError, 'Invalid right hand side of linear equation.'
      end
      
      (@lhs.to_minimodel_lin_exp - right_hand_side).post(@lhs.space, 
        relation_type, Gecode::Raw::ICL_DEF)
    end
  end
end