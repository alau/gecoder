module Gecode::Constraints::Int
  class Expression
    # Creates a domain constraint using the specified domain.
    def in(domain, options = {})
      @params.update(Gecode::Constraints::OptionUtil.decode_options(options))
      @params[:domain] = domain
      if domain.kind_of? Range
        @model.add_constraint Domain::RangeDomainConstraint.new(@model, @params)
      else
        @model.add_constraint Domain::NonRangeDomainConstraint.new(@model, 
          @params)
      end
    end
  end
  
  # A module that gathers the classes and modules used in domain constraints.
  module Domain
    # Describes a range domain constraint.
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
    
    # Describes a non-range domain constraint.
    class NonRangeDomainConstraint < Gecode::Constraints::ReifiableConstraint
      def post
        space = @model.active_space
      
        var, domain, reif_var, strength = @params.values_at(:lhs, :domain, 
          :reif, :strength)
        domain = domain.to_a
        
        (params = []) << var.bind
        params << Gecode::Raw::IntSet.new(domain, domain.size)
        params << reif_var.bind if reif_var.respond_to? :bind
        params << strength
        Gecode::Raw::dom(space, *params)
      end
      negate_using_reification
    end
  end
end