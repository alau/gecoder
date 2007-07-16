module Gecode::Constraints::IntEnum
  class Expression
    # Initiates a sort constraint. Beyond the common options the sort constraint
    # can also take the following options:
    # 
    # [:as]     Defines a target (must be an int variable enumerable) that will
    #           hold the sorted version of the original enumerable. The original
    #           enumerable will not be affected (i.e. will not necessarily be 
    #           sorted)
    # [:order]  Sets an int variable enumerable that should be used to store the
    #           order of the original enum's variables when sorted. The original
    #           enumerable will not be affected (i.e. will not necessarily be 
    #           sorted)
    # 
    # If neither of those options are specified then the original enumerable
    # will be constrained to be sorted (otherwise not). Sort constraints with
    # options do not allow negation.
    def sorted(options = {})
      # Extract and check options.
      target = options.delete(:as)
      order = options.delete(:order)
      unless target.nil? or target.respond_to? :to_int_var_array
        raise TypeError, 'Expected int var enum as :as, got ' + 
          "#{target.class}."
      end
      unless order.nil? or order.respond_to? :to_int_var_array
        raise TypeError, 'Expected int var enum as :order, got ' + 
          "#{order.class}."
      end
      
      # Extract standard options and convert to constraint.
      @params.update(Gecode::Constraints::Util.decode_options(options))
      if target.nil? and order.nil?
        @model.add_constraint Sort::SortConstraint.new(@model, @params)
      else
        # Do not allow negation.
        if @params[:negate]
          raise Gecode::MissingConstraintError, 'A negated sort with options ' +
            'is not implemented.'
        end
      
        @params.update(:target => target, :order => order)
        @model.add_constraint Sort::SortConstraintWithOptions.new(@model, 
          @params)
      end
    end
  end

  # A module that gathers the classes and modules used in sort constraints.
  module Sort
    # Describes a sort constraint with target and order.
    class SortConstraintWithOptions < Gecode::Constraints::Constraint
      def post
        if @params[:target].nil?
          # We must have a target.
          lhs = @params[:lhs]
          @params[:target] = @model.int_var_array(lhs.size, lhs.domain_range)
        end
        
        # Prepare the parameters.
        params = @params.values_at(:lhs, :target, :order, :strength).map do |param| 
          if param.respond_to? :to_int_var_array
            param.to_int_var_array
          else
            param
          end
        end.delete_if{ |param| param.nil? }
        # Post the constraint.
        Gecode::Raw::sortedness(@model.active_space, *params)
      end
    end
    
    # Describes a sort constraint.
    class SortConstraint < Gecode::Constraints::ReifiableConstraint
      def post
        lhs, strength, reif_var = @params.values_at(:lhs, :strength, :reif)
        using_reification = !reif_var.nil?
        
        # We translate the constraint into n-1 relation constraints.
        options = {:strength => 
          Gecode::Constraints::Util::PROPAGATION_STRENGTHS.invert[strength]}
        if using_reification
          reification_variables = @model.bool_var_array(lhs.size - 1)
        end
        (lhs.size - 1).times do |i|
          first, second = lhs[i, 2]
          rel_options = options.clone
          if using_reification
            # Reify each relation constraint and then bind them all together.
            rel_options[:reify] = reification_variables[i]
          end
          first.must_be.less_than_or_equal_to(second, rel_options)
        end
        if using_reification
          reification_variables.conjunction.must == reif_var
        end
      end
      negate_using_reification
    end
  end
end