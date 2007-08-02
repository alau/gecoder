module Gecode
  class FreeSetVar
    # Starts a constraint on the minimum value of the set.
    def min
      params = {:lhs => self}
      Gecode::Constraints::Set::Connection::MinExpressionStub.new(@model, params)
    end
    
    # Starts a constraint on the maximum value of the set.
    def max
      params = {:lhs => self}
      Gecode::Constraints::Set::Connection::MaxExpressionStub.new(@model, params)
    end
    
    # Starts a constraint on the sum of the set. The option :weights may 
    # optionally be given with a hash of weights as value. If it is then the 
    # weighted sum, using the hash as weight function, will be constrained. The
    # option :substitutions may also be given (with a hash as value), if it is 
    # then the sum of the set with all elements replaced according to the hash 
    # is constrained. Elements mapped to nil by the weights or substitutions 
    # hash are removed from the upper bound of the set. Only one of the two
    # options may be given at the same time.
    def sum(options = {:weights => weights = Hash.new(1)})
      if options.empty? or options.keys.size > 1
        raise ArgumentError, 'One of the options :weights and :substitutions, ' +
          'or neither, must be specified.'
      end
      params = {:lhs => self}
      unless options.empty?
        case options.keys.first
          when :substitutions: params.update(options)
          when :weights:
            weights = options[:weights]
            substitutions = Hash.new do |hash, key|
              if weights[key].nil?
                hash[key] = nil
              else
                hash[key] = key * weights[key]
              end
            end
            params.update(:substitutions => substitutions)
          else raise ArgumentError, "Unrecognized option #{options.keys.first}."
        end
      end
      Gecode::Constraints::Set::Connection::SumExpressionStub.new(@model, params)
    end
  end
end

module Gecode::Constraints::Set
  class Expression
    # Adds a constraint that forces specified values to be included in the 
    # set. This constraint has the side effect of sorting the variables in 
    # non-descending order.
    def include(variables)
      unless variables.respond_to? :to_int_var_array
        raise TypeError, "Expected int var enum, got #{variables.class}."
      end
      if @params[:negate]
        raise Gecode::MissingConstraintError, 'A negated include is not ' + 
          'implemented.'
      end
      
      @params.update(:variables => variables)
      @model.add_constraint Connection::IncludeConstraint.new(@model, @params)
    end
  end

  # A module that gathers the classes and modules used in connection 
  # constraints.
  module Connection #:nodoc:
    # Describes a CompositeStub for the min constraint which constrains the 
    # minimum value of a set variable.
    # 
    # == Examples
    # 
    #   # Constrains the minimum value of +set+ to be larger than 17.
    #   set.min.must > 17
    #   
    #   # Constrains the minimum value of +set+ to equal the integer variable 
    #   # +min+.
    #   set.min.must == min
    #   
    #   # Constrains the minimum value of +set+ to not be larger than the 
    #   # integer variable +ceil+.
    #   set.min.must_not > ceil
    #   
    #   # The same as above but reified with the boolean variable 
    #   # +is_not_above_ceiling+ and with the strength +domain+ applied.
    #   set.min.must_not_be.larger_than(ceil, :reify => :is_not_above_ceiling, 
    #     :strength => :domain) 
    class MinExpressionStub < Gecode::Constraints::Int::CompositeStub
      def constrain_equal(variable, params, constrain)
        set = params[:lhs]
        if constrain
          variable.must_be.in set.upper_bound.min..set.lower_bound.min
        end
        
        Gecode::Raw::min(@model.active_space, set.bind, variable.bind)
      end
    end
    
    # Describes a CompositeStub for the max constraint which constrains the 
    # maximum value of a set variable.
    # 
    # == Examples
    # 
    #   # Constrains the maximum value of +set+ to be larger than 17.
    #   set.max.must > 17
    #   
    #   # Constrains the maximum value of +set+ to equal the integer variable 
    #   # +max+.
    #   set.max.must == max
    #   
    #   # Constrains the maximum value of +set+ to not be less than the 
    #   # integer variable +floor+.
    #   set.max.must_not < floor
    #   
    #   # The same as above but reified with the boolean variable 
    #   # +is_not_below_floor+ and with the strength +domain+ applied.
    #   set.max.must_not_be.less_than(ceil, :reify => :is_not_below_floor, 
    #     :strength => :domain)
    class MaxExpressionStub < Gecode::Constraints::Int::CompositeStub
      def constrain_equal(variable, params, constrain)
        set = params[:lhs]
        if constrain
          variable.must_be.in set.lower_bound.max..set.upper_bound.max
        end
        
        Gecode::Raw::max(@model.active_space, set.bind, variable.bind)
      end
    end
    
    # Describes a CompositeStub for the sum constraint which constrains the 
    # sum of all values in a set variable.
    # 
    # == Examples
    # 
    #   # Constrains the sum of all values in +set+ to be larger than 17.
    #   set.sum.must > 17
    #   
    #   # Constrains the sum of all values in +set+ to equal the integer 
    #   # variable +sum+.
    #   set.sum.must == sum
    #   
    #   # Constrains the sum of all values in +set+ to not be larger than the 
    #   # integer variable +resources+.
    #   set.sum.must_not > resources
    #   
    #   # The same as above but reified with the boolean variable 
    #   # +not_over_budget+ and with the strength +domain+ applied.
    #   set.sum.must_not_be.larger_than(resources, :reify => :not_over_budget, 
    #     :strength => :domain)
    class SumExpressionStub < Gecode::Constraints::Int::CompositeStub
      def constrain_equal(variable, params, constrain)
        set, subs = params.values_at(:lhs, :substitutions)
        lub = set.upper_bound.to_a
        lub.delete_if{ |e| subs[e].nil? }
        substituted_lub = lub.map{ |e| subs[e] }
        if constrain
          # Compute the theoretical bounds of the weighted sum. This is slightly
          # sloppy since we could also use the contents of the greatest lower 
          # bound.
          min = substituted_lub.find_all{ |e| e < 0}.inject(0){ |x, y| x + y }
          max = substituted_lub.find_all{ |e| e > 0}.inject(0){ |x, y| x + y }
          variable.must_be.in min..max
        end

        Gecode::Raw::weights(@model.active_space, lub, substituted_lub, 
          set.bind, variable.bind)
      end
    end
    
    # Describes an include constraint, which constrains the set to include the
    # values of the specified enumeration of integer variables. 
    # 
    # The constraint has the side effect of sorting the integer variables in a 
    # non-descending order. It does not support reification nor negation.
    # 
    # == Examples
    # 
    #   # Constrain +set+ to include the values of all variables in 
    #   # +int_enum+.
    #   set.must.include int_enum 
    class IncludeConstraint < Gecode::Constraints::Constraint
      def post
        set, variables = @params.values_at(:lhs, :variables)
        Gecode::Raw::match(@model.active_space, set.bind, 
          variables.to_int_var_array)
      end
    end
  end
end