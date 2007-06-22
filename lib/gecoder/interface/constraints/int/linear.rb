module Gecode
  class FreeIntVar
    # Creates a linear expression where the int variables are summed.
    def +(var)
      Gecode::Constraints::Int::Linear::ExpressionNode.new(self, 
        active_space) + var
    end
    
    # Creates a linear expression where the int variable is multiplied with 
    # a constant integer.
    def *(int)
      Gecode::Constraints::Int::Linear::ExpressionNode.new(self, 
        active_space) * int
    end
    
    # Creates a linear expression where the specified variable is subtracted 
    # from this one.
    def -(var)
      Gecode::Constraints::Int::Linear::ExpressionNode.new(self, 
        active_space) - var
    end
  end
  
  module Constraints::Int
    class Expression
      private
    
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
      
      public
    
      # Add some relation selection based on whether the expression is negated.
      alias_method :pre_linear_initialize, :initialize
      def initialize(params)
        pre_linear_initialize(params)
        unless params[:negate]
          @method_relations = RELATION_TYPES
        else
          @method_relations = NEGATED_RELATION_TYPES
        end
      end
      
      # Define the relation methods.
      RELATION_TYPES.each_key do |name|
        module_eval <<-"end_code"
          def #{name}(expression, options = {})
            relation = @method_relations[:#{name}]
            strength, reif_var = 
              Gecode::Constraints::OptionUtil.decode_options(options)
            if self.simple_expression? and simple_expression?(expression)
              # A relation constraint is enough.
              post_relation_constraint(relation, expression, strength, reif_var)
            else
              post_linear_constraint(relation, expression, strength, reif_var)
            end
          end
        end_code
      end
      
      # Various aliases.
      { :== => [:equal, :equal_to],
        :>  => [:greater, :greater_than],
        :>= => [:greater_or_equal, :greater_than_or_equal_to],
        :<  => [:less, :less_than],
        :<= => [:less_or_equal, :less_than_or_equal_to]
      }.each_pair do |orig, alias_names|
        alias_names.each do |name|
          alias_method name, orig
        end
      end
      
      protected
      
      # Checks whether the given expression is simple enough to be used in a 
      # simple relation constraint. Returns true if it is, false otherwise. If
      # no expression is given then the this expression's left hand side is 
      # checked.
      def simple_expression?(expression = nil)
        if expression.nil?
          simple_expression?(@params[:lhs])
        else
          expression.kind_of?(Gecode::FreeIntVar) or expression.kind_of?(Fixnum)
        end
      end
      
      private
      
      # Places the linear constraint corresponding to the specified (integer)
      # relation type (as specified by Gecode) in relation to the specifed 
      # expression.
      # 
      # Raises TypeError if the element is of a type that doesn't allow a 
      # relation to be specified.
      def post_linear_constraint(relation_type, right_hand_side, strength, 
          reif_var)
        lhs = @params[:lhs]
          
        if lhs.kind_of? Gecode::FreeIntVar
          lhs = lhs * 1 # Convert to Gecode::Raw::LinExp
        end
        if right_hand_side.respond_to? :to_minimodel_lin_exp
          right_hand_side = right_hand_side.to_minimodel_lin_exp
        elsif right_hand_side.kind_of? Gecode::FreeIntVar
          right_hand_side = right_hand_side.bind * 1
        elsif not right_hand_side.kind_of? Fixnum
          raise TypeError, 'Invalid right hand side of linear equation.'
        end
        
        final_exp = (lhs.to_minimodel_lin_exp - right_hand_side)
        if reif_var.nil?
          final_exp.post(lhs.space, relation_type, strength)
        else
          final_exp.post(lhs.space, relation_type, reif_var)
        end
      end
      
      # Places the relation constraint corresponding to the specified (integer)
      # relation type (as specified by Gecode) in relation to the specifed 
      # element.
      # 
      # Raises TypeError if the element is of a type that doesn't allow a 
      # relation to be specified.
      def post_relation_constraint(relation_type, element, strength, reif_var)
        lhs, space = @params.values_at(:lhs, :space)
        
        if element.kind_of? FreeIntVar
          element = element.bind
        elsif !element.kind_of? Fixnum
          raise TypeError, 'Invalid right hand side of simple relation.'
        end
        
        if reif_var.nil?
          Gecode::Raw::rel(space, lhs.bind, relation_type, element, strength)
        else
          Gecode::Raw::rel(space, lhs.bind, relation_type, element, strength, 
            reif_var)
        end
      end
    end
  end
  
  # A module that gathers the classes and modules used in linear constraints.
  module Constraints::Int::Linear
    # Helper methods for linear expressions. Classes mixing in this module must
    # have a method #space which gives the space the expression is operating in. 
    module Helper
      include Gecode::Constraints::LeftHandSideMethods
      
      private
    
      OPERATION_TYPES = [:+, :-, :*]
    
      public
    
      # Define methods for the available operations.
      OPERATION_TYPES.each do |name|
        module_eval <<-"end_code"
          def #{name}(expression)
            unless expression.kind_of? ExpressionTree
              expression = ExpressionNode.new(expression)
            end
            ExpressionTree.new(self, expression, :#{name})
          end
        end_code
      end
      
      private
      
      # Produces an expression for the lhs module.
      def expression(params)
        params.update({:lhs => self, :space => space})
        Gecode::Constraints::Int::Expression.new(params)
      end
    end
    
    # Describes a linear constraint that starts with a linear expression 
    # followed by must or must_not.
    class ExpressionTree
      include Helper
    
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
    class ExpressionNode
      include Helper
    
      attr :space
    
      def initialize(value, space = nil)
        @value = value
        @space = space
      end
      
      # Converts the linear expression to an instance of 
      # Gecode::Raw::MiniModel::LinExpr
      def to_minimodel_lin_exp
        expression = @value
        if expression.kind_of? Gecode::FreeIntVar
          # Minimodel requires that we do this first.
          expression = expression.bind * 1
        end
        expression
      end
    end
  end
end