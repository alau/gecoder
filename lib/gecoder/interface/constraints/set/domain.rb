module Gecode::Constraints::Set
  class Expression
    Gecode::Constraints::Util::SET_RELATION_TYPES.each_pair do |name, type|
      module_eval <<-"end_code"
        # Creates a domain constraint using the specified constant set.
        def #{name}(constant_set, options = {})
          add_domain_constraint(:#{name}, constant_set, options)
        end
      end_code
    end
    alias_set_methods
    
    private
    
    # Adds a domain constraint for the specified relation name, constant set
    # and options.
    def add_domain_constraint(relation_name, constant_set, options)
      unless Gecode::Constraints::Util.constant_set? constant_set
        raise TypeError, "Expected constant set, got #{constant_set.class}."
      end
      @params[:rhs] = constant_set
      @params[:relation] = relation_name
      @params.update Gecode::Constraints::Set::Util.decode_options(options)
      if relation_name == :==
        @model.add_constraint Domain::EqualityDomainConstraint.new(@model, 
          @params)
      else
        @model.add_constraint Domain::DomainConstraint.new(@model, @params)
      end
    end
  end
  
  # A module that gathers the classes and modules used in domain constraints.
  module Domain #:nodoc:
    # Describes a domain constraint which constrains a set to be equal to a 
    # constant set.
    # 
    # == Examples
    # 
    #   # +set+ must equal [1,2,5]
    #   set.must == [1,2,5]
    #   
    #   # +set+ must not equal 1..67
    #   set.must_not == 1..67
    #   
    #   # +set+ must equal the singleton set 0. The constraint is reified with
    #   # the boolean varaible +is_singleton_zero+.
    #   set.must.equal(0, :reify => is_singleton_zero)
    class EqualityDomainConstraint < Gecode::Constraints::ReifiableConstraint
      def post
        var, domain, reif_var, negate = @params.values_at(:lhs, :rhs, :reif, 
          :negate)
        if negate
          rel_type = Gecode::Constraints::Util::NEGATED_SET_RELATION_TYPES[:==]
        else
          rel_type = Gecode::Constraints::Util::SET_RELATION_TYPES[:==]
        end
        
        (params = []) << var.bind
        params << rel_type
        params << Gecode::Constraints::Util.constant_set_to_params(domain)
        params << reif_var.bind if reif_var.respond_to? :bind
        Gecode::Raw::dom(@model.active_space, *params.flatten)
      end
    end
  
    # Describes a domain constraint which constrains a set to have a specific
    # relation to a constant set. A constant set may be specified in three ways
    # 
    # [Fixnum]                Represents a singleton set.
    # [Range]                 Represents a set containing all elements in the 
    #                         range. This represents the set more efficiently 
    #                         than when another enumeration with the same 
    #                         elements are used.
    # [Enumeration of Fixnum] Represents a set containing the enumeration’s 
    #                         elements.
    #
    # The relations allowed are the same as in 
    # <tt>Set::Relation::RelationConstraint</tt>.
    #
    # == Examples
    # 
    #   # +set+ must be subset of [1,2,5]
    #   set.must_be.subset_of [1,2,5]
    #   
    #   # +set+ must be disjoint with 1..67
    #   set.must_be.disjoint_with 1..67
    #   
    #   # +set+ must not be a superset of [0].
    #   set.must_not_be.superset_of 0
    #   
    #   # +set+ must be subset of [1,3,5,7]. The constraint is reified with
    #   # the boolean varaible +only_constains_odd_values+.
    #   set.must_be.subset_of([1.3.5.7], :reify => only_contains_odd_values) 
    class DomainConstraint < Gecode::Constraints::ReifiableConstraint
      def post
        var, domain, reif_var, relation = @params.values_at(:lhs, :rhs, :reif, 
          :relation)
        
        (params = []) << var.bind
        params << Gecode::Constraints::Util::SET_RELATION_TYPES[relation]
        params << Gecode::Constraints::Util.constant_set_to_params(domain)
        params << reif_var.bind if reif_var.respond_to? :bind
        Gecode::Raw::dom(@model.active_space, *params.flatten)
      end
      negate_using_reification
    end
  end
end