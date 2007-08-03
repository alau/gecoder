module Gecode
  class FreeIntVar
    # Creates a linear expression where the int variables are summed.
    def +(var)
      Gecode::Constraints::Int::Linear::ExpressionNode.new(self, 
        @model) + var
    end
    
    alias_method :pre_linear_mult, :* if instance_methods.include? '*'

    # Creates a linear expression where the int variable is multiplied with 
    # a constant integer.
    def *(int)
      if int.kind_of? Fixnum
        Gecode::Constraints::Int::Linear::ExpressionNode.new(self, 
          @model) * int
      else
        pre_linear_mult(int) if respond_to? :pre_linear_mult
      end
    end
    
    # Creates a linear expression where the specified variable is subtracted 
    # from this one.
    def -(var)
      Gecode::Constraints::Int::Linear::ExpressionNode.new(self, 
        @model) - var
    end
  end
  
  module Constraints::Int
    class Expression #:nodoc:
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
      alias_comparison_methods
      
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
        if not (right_hand_side.respond_to? :to_minimodel_lin_exp or
            right_hand_side.kind_of? Gecode::FreeIntVar or 
            right_hand_side.kind_of? Fixnum)
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
        @model.add_constraint Linear::SimpleRelationConstraint.new(@model, 
          @params.update(:relation_type => relation_type, :element => element))
      end
    end
  end
  
  # A module that gathers the classes and modules used in linear constraints.
  module Constraints::Int::Linear #:nodoc:
    # Linear constraints specify that an integer variable must have a linear 
    # equation containing variables must hold. The same relations and options
    # used in +SimpleRelationConstraint+ can also be used for linear 
    # constraints.
    # 
    # == Examples
    # 
    #   # The sum of the int variables +x+ and +y+ must equal +z+ + 3.
    #   (x + y).must == z + 3
    #   
    #   # Another way of writing the above. 
    #   z.must == x + y - 3
    #   
    #   # The inequality 10(x + y) > 3x must not hold. 
    #   (x + y)*10.must_not > x*3
    #   
    #   # Specifies the above, but reifies the constraint with the boolean 
    #   # variable +bool+ and gives it propagation strength +domain+.
    #   (x + y)*10.must_not_be.greater_than(x*3, :reify => bool, :strength => :domain)
    class LinearConstraint < Gecode::Constraints::ReifiableConstraint
      def post
        lhs, rhs, relation_type, reif_var, strength = @params.values_at(:lhs, 
          :rhs, :relation_type, :reif, :strength)
        reif_var = reif_var.bind if reif_var.respond_to? :bind
        if rhs.respond_to? :to_minimodel_lin_exp
          rhs = rhs.to_minimodel_lin_exp
        elsif rhs.kind_of? Gecode::FreeIntVar
          rhs = rhs.bind * 1
        end

        final_exp = (lhs.to_minimodel_lin_exp - rhs)
        if reif_var.nil?
          final_exp.post(@model.active_space, relation_type, strength)
        else
          final_exp.post(@model.active_space, relation_type, reif_var)
        end
      end
    end

    # Simple relation constraints specify that an integer variable must have a
    # specified relation to a constant integer or another integer variable. The 
    # following relations are supported (the aliases of each relation are also 
    # listed).
    # 
    # * <, lesser, lesser_than
    # * >, greater, greater_than
    # * >=, greater_or_equal, greater_than_or_equal_to
    # * <=, less_or_equal, less_than_or_equal_to
    # * ==, equal, equal_to
    # 
    # Each can be negated by using +must_not+ instead of +must+.
    # 
    # Two options (given as a hash) are available:
    # 
    # [strength] Specifies the propagation strength of the constraint. Must be
    #            one of +value+, +bounds+, +domain+ and +default+. The
    #            strength generally progresses as +value+ -> +bounds+ -> 
    #            +domain+ (+value+ being the weakest, but usually cheapest, 
    #            while +domain+ is the strongest but usually costly).
    # [reify]    Specifies a boolean variable that should be used for 
    #            reification (see +ReifiableConstraint+).
    # 
    # == Examples
    # 
    #   # Int variable +x+ must not equal 0.
    #   x.must_not.equal(0)
    #   
    #   # Another way of writing the above. 
    #   x.must_not == 0
    #   
    #   # +x+ must be strictly larger than +y+.
    #   x.must > y
    #   
    #   # Specifies the above, but reifies the constraint with the boolean 
    #   # variable +bool+.
    #   x.must_be.greater_than(y, :reify => bool)
    class SimpleRelationConstraint < Gecode::Constraints::ReifiableConstraint
      def post
        # Fetch the parameters to Gecode.
        lhs, relation, rhs, reif_var, strength = @params.values_at(:lhs, 
          :relation_type, :element, :reif, :strength)
          
        rhs = rhs.bind if rhs.respond_to? :bind
        if reif_var.nil?
          Gecode::Raw::rel(@model.active_space, lhs.bind, relation, rhs, 
            strength)
        else
          Gecode::Raw::rel(@model.active_space, lhs.bind, relation, rhs, 
            reif_var.bind, strength)
        end
      end
    end
  
    # Helper methods for linear expressions. Classes mixing in this module must
    # have a method #model which gives the model the expression is operating in. 
    module Helper #:nodoc:
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
    class ExpressionTree #:nodoc:
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
    class ExpressionNode #:nodoc:
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