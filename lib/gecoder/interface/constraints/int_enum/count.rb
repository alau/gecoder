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
      return Gecode::Constraints::IntEnum::Count::ExpressionStub.new(
        @model, params)
    end
  end
end

module Gecode::Constraints::IntEnum
  class Expression
    # Posts a distinct constraint on the variables in the enum.
    def distinct(options = {})
      if @params[:negate]
        # The best we could implement it as from here would be a bunch of 
        # reified pairwise equality constraints. 
        raise Gecode::MissingConstraintError, 'A negated distinct is not ' + 
          'implemented.'
      end
    
      @model.add_constraint Distinct::DistinctConstraint.new(@model, 
        @params.update(Gecode::Constraints::Util.decode_options(options)))
    end
  end
  
  # A module that gathers the classes and modules used in count constraints.
  module Count
    # Describes an expression stub started with an int var enum followed by
    # #count .
    class ExpressionStub < Gecode::Constraints::ExpressionStub
      include Gecode::Constraints::LeftHandSideMethods
      
      private
      
      # Produces an expression with the element for the lhs module.
      def expression(params)
        params.update(@params)
        Gecode::Constraints::IntEnum::Count::Expression.new(@model, params)
      end
    end
    
    # Describes an expression 
    class Expression < Gecode::Constraints::IntEnum::Expression
      def initialize(model, params)
        super
        unless params.has_key? :element
          raise ArgumentError, 'Count expression is missing element parameter.'
        end
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
    
    # Describes a count constraint.
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
end