module Gecode
  class FreeIntVar
    # Specifies that a constraint must hold for the integer variable.
    def must
      Gecode::IntVarConstraintExpression.new(active_space, self.bind)
    end
    
    # Specifies that the negation of a constraint must hold for the integer 
    # variable.
    def must_not
      Gecode::IntVarConstraintExpression.new(active_space, self.bind, true)
    end
  end
  
  # Describes a constraint expression that starts with a single integer variable
  # followed by must or must_not.
  class IntVarConstraintExpression
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
    
    # Constructs a new expression with the specified space and (bound) variable 
    # as source. The expression can optionally be negated.
    def initialize(space, var, negate = false)
      @space = space
      @var = var
      unless negate
        @method_relations = RELATION_TYPES
      else
        @method_relations = NEGATED_RELATION_TYPES
      end
    end
    
    RELATION_TYPES.each_key do |name|
      module_eval <<-"end_code"
        def #{name}(element)
          post_relation_constraint(@method_relations[:#{name}], element)
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
    def post_relation_constraint(relation_type, element)
      if element.kind_of? Fixnum
        Gecode::Raw::rel(@space, @var, relation_type, element, 
          Gecode::Raw::ICL_DEF)
      else
        raise TypeError, 'Relations only allow Fixnum.'
      end
    end
  end
end