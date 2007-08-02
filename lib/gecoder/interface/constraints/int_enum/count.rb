module Gecode
  module IntEnumMethods
    # Specifies that a specific element should be counted, starting a count
    # constraint. The element can be either an int var or a fixnum.
    def count(element)
      unless element.kind_of?(FreeIntVar) or element.kind_of?(Fixnum)
        raise TypeError, 'Elements used with count can not be of type ' + 
          "#{element.class}."
      end
      params = {:lhs => self, :element => element}
      Gecode::Constraints::SimpleExpressionStub.new(@model, params) do |m, ps|
        Gecode::Constraints::IntEnum::Count::Expression.new(m, ps)
      end
    end
  end
end

# A module that gathers the classes and modules used in count constraints.
module Gecode::Constraints::IntEnum::Count #:nodoc:
  # Describes an expression 
  class Expression < Gecode::Constraints::IntEnum::Expression #:nodoc:
    def initialize(model, params)
      super
      unless params[:negate]
        @method_relations = Gecode::Constraints::Util::RELATION_TYPES
      else
        @method_relations = Gecode::Constraints::Util::NEGATED_RELATION_TYPES
      end
    end
    
    Gecode::Constraints::Util::RELATION_TYPES.each_pair do |name, type|
      class_eval <<-"end_code"
        def #{name}(expression, options = {})
          unless expression.kind_of?(Fixnum) or 
              expression.kind_of?(Gecode::FreeIntVar)
            raise TypeError, 'Invalid right hand side of count constraint: ' + 
              "\#{expression.class}."
          end
        
          relation = @method_relations[:#{name}]
          @params.update(Gecode::Constraints::Util.decode_options(options))
          @params.update(:rhs => expression, :relation_type => relation)
          @model.add_constraint CountConstraint.new(@model, @params)
        end
      end_code
    end
    alias_comparison_methods
  end
  
  # Describes a count constraint, which constrains the number of times a value
  # (constant or a variable) may occurr in an enumeration of integer variables
  # or constant integers.
  # 
  # All relations available for +SimpleRelationConstraint+ can be used with
  # count constraints. Negation and reification is supported.
  # 
  # == Examples
  # 
  #   # Constrain an enumeration of constant integers to contain the value of
  #   # the integer variable +x+ more than once.
  #   wrap_enum([1,3,17]).count(x) > 1
  # 
  #   # Constrain +int_enum+ to not contain 0 exactly once.
  #   int_enum.count(0).must_not == 1
  #   
  #   # Constrain +int_enum+ to contain +x+ exactly +x_count+ times.
  #   int_enum.count(x).must == x_count
  #   
  #   # Reifies the constraint that +int_enum+ has +x+ zeros with the boolean
  #   # variable +has_x_zeros+ and selects the strength +domain+.
  #   int_enum.count(0).must.equal(x, :reify => has_x_zeros, 
  #     :strength => :domain)
  class CountConstraint < Gecode::Constraints::ReifiableConstraint
    def post
      lhs, element, relation_type, rhs, strength, reif_var = 
        @params.values_at(:lhs, :element, :relation_type, :rhs, :strength, 
          :reif)
      
      # Bind variables if needed.
      element = element.bind if element.respond_to? :bind
      rhs = rhs.bind if rhs.respond_to? :bind
      
      # Post the constraint to gecode.
      if reif_var.nil?
        Gecode::Raw::count(@model.active_space, lhs.to_int_var_array, 
          element, relation_type, rhs, strength)
      else
        # We use a proxy int variable to get the reification.
        proxy = @model.int_var(rhs.min..rhs.max)
        rel = Gecode::Constraints::Util::RELATION_TYPES.invert[relation_type]
        proxy.must.send(rel, @params[:rhs], :reify => reif_var)
        Gecode::Raw::count(@model.active_space, lhs.to_int_var_array, 
          element, Gecode::Raw::IRT_EQ, proxy.bind, strength)
      end
    end
  end
end