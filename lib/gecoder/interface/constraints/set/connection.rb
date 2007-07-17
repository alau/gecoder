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
  module Connection
    # Describes an expression stub started with an int var following by #min.
    class MinExpressionStub < Gecode::Constraints::Int::CompositeStub
      def constrain_equal(variable, params)
        set = params[:lhs]
        if variable.nil?
          variable = @model.int_var(set.upper_bound.min, set.lower_bound.min)
        end
        
        @model.add_interaction do
          Gecode::Raw::min(@model.active_space, set.bind, variable.bind)
        end
        return variable
      end
    end
    
    # Describes an expression stub started with an int var following by #max.
    class MaxExpressionStub < Gecode::Constraints::Int::CompositeStub
      def constrain_equal(variable, params)
        set = params[:lhs]
        if variable.nil?
          variable = @model.int_var(set.upper_bound.max, set.lower_bound.max)
        end
        
        @model.add_interaction do
          Gecode::Raw::max(@model.active_space, set.bind, variable.bind)
        end
        return variable
      end
    end
    
    # Describes an expression stub started with an int var following by #max.
    class SumExpressionStub < Gecode::Constraints::Int::CompositeStub
      def constrain_equal(variable, params)
        set, subs = params.values_at(:lhs, :substitutions)
        lub = set.upper_bound.to_a
        lub.delete_if{ |e| subs[e].nil? }
        substituted_lub = lub.map{ |e| subs[e] }
        if variable.nil?
          # Compute the theoretical bounds of the weighted sum. This is slightly
          # sloppy since we could also use the contents of the greatest lower 
          # bound.
          min = substituted_lub.find_all{ |e| e < 0}.inject(0){ |x, y| x + y }
          max = substituted_lub.find_all{ |e| e > 0}.inject(0){ |x, y| x + y }
          variable = @model.int_var(min..max)
        end

        @model.add_interaction do
          Gecode::Raw::weights(@model.active_space, lub, substituted_lub, 
            set.bind, variable.bind)
        end
        return variable
      end
    end
    
    # Describes a constraint that constrains a set to include a number of 
    # integer variables.
    class IncludeConstraint < Gecode::Constraints::Constraint
      def post
        set, variables = @params.values_at(:lhs, :variables)
        Gecode::Raw::match(@model.active_space, set.bind, 
          variables.to_int_var_array)
      end
    end
  end
end