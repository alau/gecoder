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
  module Domain
    # Describes a domain constraint for equality.
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
  
    # Describes a domain constraint for the relations other than equality.
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