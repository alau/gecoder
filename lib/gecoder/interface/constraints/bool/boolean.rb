module Gecode
  class FreeBoolVar
    # Initiates a boolean constraint with this variable or +var+.
    def |(var)
      Constraints::Bool::ExpressionNode.new(self, @model) | var
    end
    
    # Initiates a boolean constraint with this variable and +var+.
    def &(var)
      Constraints::Bool::ExpressionNode.new(self, @model) & var
    end
    
    # Initiates a boolean constraint with this variable exclusive or +var+.
    def ^(var)
      Constraints::Bool::ExpressionNode.new(self, @model) ^ var
    end
    
    # Initiates a boolean constraint with this variable implies +var+.
    def implies(var)
      Constraints::Bool::ExpressionNode.new(self, @model).implies var
    end
  end
  
  # A module that gathers the classes and modules used in boolean constraints.
  module Constraints::Bool
    # Describes a boolean expression (following after must*).
    class Expression #:nodoc:
      def ==(expression, options = {})
        if expression.kind_of? Gecode::Constraints::Int::Linear::ExpressionTree
          return expression.must == @params[:lhs]
        end
        unless expression.respond_to? :to_minimodel_bool_expr
          expression = Constraints::Bool::ExpressionNode.new(expression, @model)
        end
        @params.update Gecode::Constraints::Util.decode_options(options)
        @params.update(:lhs => @params[:lhs], :rhs => expression)
        @model.add_constraint BooleanConstraint.new(@model, @params)
      end
      alias_comparison_methods
      
      # Constrains the boolean expression to imply the specified expression.
      def imply(expression, options = {})
        @params.update Gecode::Constraints::Util.decode_options(options)
        @params.update(:lhs => @params[:lhs].implies(expression), :rhs => true)
        @model.add_constraint BooleanConstraint.new(@model, @params)
      end
      
      # Constrains the boolean expression to be true.
      def true(options = {})
        @params.update Gecode::Constraints::Util.decode_options(options)
        @model.add_constraint BooleanConstraint.new(@model, 
          @params.update(:rhs => true))
      end
      
      # Constrains the boolean expression to be false.
      def false(options = {})
        @params[:negate] = !@params[:negate]
        self.true
      end
    end
    
    # Describes a constraint on a boolean expression.
    # 
    # == Boolean expressions
    # 
    # A boolean expression consists of several boolean variable with various 
    # boolean operators. The available operators are:
    # 
    # [<tt>|</tt>] Or
    # [<tt>&</tt>] And
    # [<tt>^</tt>] Exclusive or
    # [+implies+]  Implication
    # 
    # === Examples
    # 
    #   # +b1+ and +b2+
    #   b1 & b2
    #   
    #   # (+b1+ and +b2+) or +b3+ 
    #   (b1 & b1) | b3
    # 
    #   # (+b1+ and +b2+) or (+b3+ exclusive or +b1+)
    #   (b1 & b2) | (b3 ^ b1)
    #   
    #   # (+b1+ implies +b2+) and (+b3+ implies +b2+)
    #   (b1.implies b2) & (b3.implies b2)
    #   
    # == Domain
    # 
    # A domain constraint just specifies that a boolean expression must be true
    # or false. Negation and reification are supported.
    # 
    # === Examples
    # 
    #   # +b1+ and +b2+ must be true.
    #   (b1 & b2).must_be.true
    #   
    #   # (+b1+ implies +b2+) and (+b3+ implies +b2+) must be false.
    #   ((b1.implies b2) & (b3.implies b2)).must_be.false
    # 
    #   # +b1+ and +b2+ must be true. We reify it with +bool+ and select the
    #   # strength +domain+.
    #   (b1 & b2).must_be.true(:reify => bool, :strength => :domain)
    # 
    # == Equality
    # 
    # A constraint with equality specifies that two boolean expressions must be
    # equal. Negation and reification are supported. Any of <tt>==</tt>, 
    # +equal+ and +equal_to+ may be used for equality.
    # 
    # === Examples
    # 
    #   # +b1+ and +b2+ must equal +b1+ or +b2+.
    #   (b1 & b2).must == (b1 | b2)
    #   
    #   # +b1+ and +b2+ must not equal +b3+. We reify it with +bool+ and select 
    #   # the strength +domain+.
    #   (b1 & b2).must_not.equal(b3, :reify => bool, :select => :domain)
    #   
    # == Implication
    # 
    # A constraint using +imply+ specified that one boolean expression must
    # imply the other. Negation and reification are supported.
    # 
    # === Examples
    #   
    #   # +b1+ must imply +b2+
    #   b1.must.imply b2
    #   
    #   # +b1+ and +b2+ must not imply +b3+. We reify it with +bool+ and select
    #   # +domain+ as strength.
    #   (b1 & b2).must_not.imply b3
    class BooleanConstraint < Gecode::Constraints::ReifiableConstraint
      def post
        lhs, rhs, negate, reif_var = 
          @params.values_at(:lhs, :rhs, :negate, :reif)
        space = (lhs.model || rhs.model).active_space

        if lhs.kind_of?(Gecode::FreeBoolVar)
          lhs = Constraints::Bool::ExpressionNode.new(lhs, @model)
        end

        bot_eqv = Gecode::Raw::IRT_EQ
        bot_xor = Gecode::Raw::IRT_NQ

        if rhs.respond_to? :to_minimodel_bool_expr
          if reif_var.nil?
            tree = ExpressionTree.new(lhs, 
              Gecode::Raw::MiniModel::BoolExpr::NT_EQV, rhs)
            tree.to_minimodel_bool_expr.post(space, !negate, 
              *propagation_options)
          else
            tree = ExpressionTree.new(lhs, 
              Gecode::Raw::MiniModel::BoolExpr::NT_EQV, rhs)
            var = tree.to_minimodel_bool_expr.post(space, *propagation_options)
            Gecode::Raw::rel(space, var, (negate ? bot_xor : bot_eqv),
              reif_var.bind, *propagation_options)
          end
        else
          should_hold = !negate & rhs
          if reif_var.nil?
            lhs.to_minimodel_bool_expr.post(space, should_hold, 
              *propagation_options)
          else
            var = lhs.to_minimodel_bool_expr.post(space, *propagation_options)
            Gecode::Raw::rel(space, var, 
              (should_hold ? bot_eqv : bot_xor),
              reif_var.bind, *propagation_options)
          end
        end
      end
    end
  
    # A module containing the methods for the basic boolean operations. Depends
    # on that the class mixing it in defined #model.
    module OperationMethods #:nodoc
      include Gecode::Constraints::LeftHandSideMethods
      
      private
    
      # Maps the names of the methods to the corresponding bool constraint in 
      # Gecode.
      OPERATION_TYPES = {
        :|        => Gecode::Raw::MiniModel::BoolExpr::NT_OR,
        :&        => Gecode::Raw::MiniModel::BoolExpr::NT_AND,
        :^        => Gecode::Raw::MiniModel::BoolExpr::NT_XOR,
        :implies  => Gecode::Raw::MiniModel::BoolExpr::NT_IMP
      }
      
      public
      
      OPERATION_TYPES.each_pair do |name, operation|
        module_eval <<-"end_code"
          def #{name}(expression)
            unless expression.kind_of? ExpressionTree
              expression = ExpressionNode.new(expression)
            end
            ExpressionTree.new(self, #{operation}, expression)
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
    class ExpressionTree #:nodoc:
      include OperationMethods
    
      # Constructs a new expression with the specified binary operation 
      # applied to the specified trees.
      def initialize(left_tree, operation, right_tree)
        @left = left_tree
        @operation = operation
        @right = right_tree
      end
      
      # Returns a MiniModel boolean expression representing the tree.
      def to_minimodel_bool_expr
        Gecode::Raw::MiniModel::BoolExpr.new(
          @left.to_minimodel_bool_expr, @operation, 
          @right.to_minimodel_bool_expr)
      end
      
      # Fetches the space that the expression's variables is in.
      def model
        @left.model || @right.model
      end
    end
  
    # Describes a single node in a boolean expression.
    class ExpressionNode #:nodoc:
      include OperationMethods
    
      attr :model
    
      def initialize(value, model = nil)
        unless value.kind_of?(Gecode::FreeBoolVar)
          raise TypeError, 'Invalid type used in boolean equation: ' +
            "#{value.class}."
        end
        @value = value
        @model = model
      end
      
      # Returns a MiniModel boolean expression representing the tree.
      def to_minimodel_bool_expr
        Gecode::Raw::MiniModel::BoolExpr.new(@value.bind)
      end
    end
  end
end
