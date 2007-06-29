module Gecode
  class FreeIntVar
    # Creates a linear expression where the int variables are summed.
    def +(var)
      Gecode::Constraints::Int::Linear::ExpressionNode.new(self, 
        @model) + var
    end
    
    # Creates a linear expression where the int variable is multiplied with 
    # a constant integer.
    def *(int)
      Gecode::Constraints::Int::Linear::ExpressionNode.new(self, 
        @model) * int
    end
    
    # Creates a linear expression where the specified variable is subtracted 
    # from this one.
    def -(var)
      Gecode::Constraints::Int::Linear::ExpressionNode.new(self, 
        @model) - var
    end
  end
  
  module Constraints::Int
    class Expression
      private
    
      # Various method aliases for the class. Maps the original name to an 
      # array of aliases.
      METHOD_ALIASES = { 
        :== => [:equal, :equal_to],
        :>  => [:greater, :greater_than],
        :>= => [:greater_or_equal, :greater_than_or_equal_to],
        :<  => [:less, :less_than],
        :<= => [:less_or_equal, :less_than_or_equal_to]
      }
      
      public
    
      # Add some relation selection based on whether the expression is negated.
      alias_method :pre_linear_initialize, :initialize
      def initialize(model, params)
        pre_linear_initialize(model, params)
        unless params[:negate]
          @method_relations = Constraints::Util::RELATION_TYPES
        else
          @method_relations = Constraints::Util::NEGATED_RELATION_TYPES
        end
      end
      
      # Define the relation methods.
      Constraints::Util::RELATION_TYPES.each_key do |name|
        module_eval <<-"end_code"
          def #{name}(expression, options = {})
            relation = @method_relations[:#{name}]
            @params.update(
              Gecode::Constraints::Util.decode_options(options))
            if self.simple_expression? and simple_expression?(expression)
              # A relation constraint is enough.
              add_relation_constraint(relation, expression)
            else
              add_linear_constraint(relation, expression)
            end
          end
        end_code
      end
      
      # Various aliases.
      METHOD_ALIASES.each_pair do |orig, alias_names|
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
      def add_linear_constraint(relation_type, right_hand_side)
        # Bind parameters.
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
        
        @params.update(:relation_type => relation_type, :lhs => lhs, 
          :rhs => right_hand_side)
        @model.add_constraint Linear::LinearConstraint.new(@model, @params)
      end
      
      # Places the relation constraint corresponding to the specified (integer)
      # relation type (as specified by Gecode) in relation to the specifed 
      # element.
      def add_relation_constraint(relation_type, element)
        # Bind parameters.
        @params[:lhs] = @params[:lhs].bind
        if element.kind_of? FreeIntVar
          element = element.bind
        end
      
        @model.add_constraint Linear::SimpleRelationConstraint.new(@model, 
          @params.update(:relation_type => relation_type, :element => element))
      end
    end
  end
  
  # A module that gathers the classes and modules used in linear constraints.
  module Constraints::Int::Linear
    # Describes a linear constraint.
    class LinearConstraint < Gecode::Constraints::ReifiableConstraint
      def post
        lhs, rhs, relation_type, reif_var, strength = @params.values_at(:lhs, 
          :rhs, :relation_type, :reif, :strength)
        reif_var = reif_var.bind if reif_var.respond_to? :bind

        final_exp = (lhs.to_minimodel_lin_exp - rhs)
        if reif_var.nil?
          final_exp.post(@model.active_space, relation_type, strength)
        else
          final_exp.post(@model.active_space, relation_type, reif_var)
        end
      end
    end
    
    # Describes a simple relation constraint.
    class SimpleRelationConstraint < Gecode::Constraints::ReifiableConstraint
      def post        
        # Fetch the parameters to Gecode.
        params = @params.values_at(:lhs, :relation_type, :element, :reif, 
          :strength)
        params[3] = params[3].bind unless params[3].nil? # Bind reification var.
        params.delete_if{ |x| x.nil? }
        Gecode::Raw::rel(@model.active_space, *params)
      end
    end
  
    # Helper methods for linear expressions. Classes mixing in this module must
    # have a method #model which gives the model the expression is operating in. 
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
        params.update(:lhs => self)
        Gecode::Constraints::Int::Expression.new(model, params)
      end
    end
    
    # Describes a binary tree of expression nodes which together form a linear 
    # expression.
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
      def model
        @left.model || @right.model
      end
    end
    
    # Describes a single node in a linear expression.
    class ExpressionNode
      include Helper
    
      attr :model
    
      def initialize(value, model = nil)
        @value = value
        @model = model
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