module Gecode::Constraints::Int
  class Expression
    # Creates a domain constraint using the specified domain.
    def in(domain, options = {})
      @params.update(Gecode::Constraints::Util.decode_options(options))
      @params[:domain] = domain
      if domain.kind_of? Range
        @model.add_constraint Domain::RangeDomainConstraint.new(@model, @params)
      elsif domain.kind_of?(Enumerable) and domain.all?{ |e| e.kind_of? Fixnum }
        @model.add_constraint Domain::EnumDomainConstraint.new(@model, 
          @params)
      else
        raise TypeError, "Expected integer enumerable, got #{domain.class}."
      end
    end
  end
  
  # A module that gathers the classes and modules used in domain constraints.
  module Domain #:nodoc:
    # Range domain constraints specify that an integer variable must be 
    # contained within a specified range of integers. Supports reification and
    # negation.
    # 
    # == Examples
    # 
    #   # +x+ must be in the range 1..10
    #   x.must_be.in 1..10
    #   
    #   # +x+ must not be in the range -5...5
    #   x.must_not_be.in -5...5
    #   
    #   # Specifies the above, but but reifies the constraint with the boolean 
    #   # variable +bool+ and specified +value+ as strength.
    #   x.must_not_be.in(-5...5, :reify => bool, :strength => :value)
    class RangeDomainConstraint < Gecode::Constraints::ReifiableConstraint
      def post
        var, domain, reif_var, strength = @params.values_at(:lhs, :domain, 
          :reif, :strength)
        (params = []) << var.bind
        params << domain.first << domain.last
        params << reif_var.bind if reif_var.respond_to? :bind
        params << strength
        Gecode::Raw::dom(@model.active_space, *params)
      end
      negate_using_reification
    end
    
    # Enum domain constraints specify that an integer variable must be contained
    # in an enumeration of integers. Supports reification and negation.
    # 
    # == Examples
    # 
    #   # +x+ must be in the enumeration [3,5,7].
    #   x.must_be.in [3,5,7]
    #   
    #   # +x+ must not be in the enumeration [5,6,7,17].
    #   x.must_not_be.in [5,6,7,17]
    #   
    #   # Specifies the above, but but reifies the constraint with the boolean 
    #   # variable +bool+ and specified +value+ as strength.
    #   x.must_not_be.in(-[5,6,7,17], :reify => bool, :strength => :value)
    class EnumDomainConstraint < Gecode::Constraints::ReifiableConstraint
      def post
        space = @model.active_space
      
        var, domain, reif_var, strength = @params.values_at(:lhs, :domain, 
          :reif, :strength)
        
        (params = []) << var.bind
        params << Gecode::Constraints::Util.constant_set_to_int_set(domain)
        params << reif_var.bind if reif_var.respond_to? :bind
        params << strength
        Gecode::Raw::dom(space, *params)
      end
      negate_using_reification
    end
  end
end