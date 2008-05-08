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
        unless expression.kind_of?(ExpressionTree) or 
            expression.kind_of?(Gecode::FreeBoolVar) or 
            expression.kind_of?(TrueClass) or expression.kind_of?(FalseClass) or
            expression.respond_to?(:to_minimodel_lin_exp)
          raise TypeError, 'Invalid right hand side of boolean equation.'
        end
        
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
        
        # TODO: It should be possible to reduce the number of necessary 
        # variables and constraints a bit by altering the way that the top node
        # is posted, using its constraint for reification etc when possible. 
        
        if rhs.respond_to? :bind
          if reif_var.nil?
            Gecode::Raw::rel(space, lhs.bind, Gecode::Raw::BOT_EQV, rhs.bind, 
              (!negate ? 1 : 0), *propagation_options)
          else
            if negate
              Gecode::Raw::rel(space, lhs.bind, Gecode::Raw::BOT_XOR, rhs.bind, 
                reif_var.bind, *propagation_options)
            else
              Gecode::Raw::rel(space, lhs.bind, Gecode::Raw::BOT_EQV, rhs.bind, 
                reif_var.bind, *propagation_options)
            end
          end
        else
          should_hold = !negate & rhs
          if reif_var.nil?
            Gecode::Raw::MiniModel::BoolExpr.new(lhs.bind).post(space, 
              should_hold, *propagation_options)
          else
            Gecode::Raw::rel(space, lhs.bind, Gecode::Raw::BOT_EQV, 
              reif_var.bind, (should_hold ? 1 : 0), *propagation_options)
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
        :|        => Gecode::Raw::BOT_OR,
        :&        => Gecode::Raw::BOT_AND,
        :^        => Gecode::Raw::BOT_XOR,
        :implies  => Gecode::Raw::BOT_IMP
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
              Gecode::Raw::rel(model.active_space, var1.bind, #{operation}, 
                var2.bind, new_var.bind, Gecode::Raw::ICL_DEF, 
                Gecode::Raw::PK_DEF)
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
    class ExpressionTree #:nodoc:
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
    class ExpressionNode #:nodoc:
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