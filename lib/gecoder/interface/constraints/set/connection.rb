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
    
    # Starts a constraint on the sum of the set. A hash of weights may 
    # optionally be given. If it is then the weighted sum, using the hash as
    # weight function, will be constrained. Elements mapped to nil by the weight
    # hash are removed from the upper bound of the set.
    def sum(weights = Hash.new(1))
      params = {:lhs => self, :weights => weights}
      Gecode::Constraints::Set::Connection::SumExpressionStub.new(@model, params)
    end
  end
end

module Gecode::Constraints::Set
  # A module that gathers the classes and modules used in connection 
  # constraints.
  module Connection
    # Describes an expression stub started with an int var following by #min.
    class MinExpressionStub < Gecode::Constraints::Int::CompositeStub
      def constrain_equal(variable, params)
        set = params[:lhs]
        if variable.nil?
          variable = @model.int_var(set.lub_min, set.glb_min)
        end
        
        Gecode::Raw::min(@model.active_space, set.bind, variable.bind)
        return variable
      end
    end
    
    # Describes an expression stub started with an int var following by #max.
    class MaxExpressionStub < Gecode::Constraints::Int::CompositeStub
      def constrain_equal(variable, params)
        set = params[:lhs]
        if variable.nil?
          variable = @model.int_var(set.lub_max, set.glb_max)
        end
        
        Gecode::Raw::max(@model.active_space, set.bind, variable.bind)
        return variable
      end
    end
    
    # Describes an expression stub started with an int var following by #max.
    class SumExpressionStub < Gecode::Constraints::Int::CompositeStub
      def constrain_equal(variable, params)
        set, weights = params.values_at(:lhs, :weights)
        lub = set.lub
        lub.delete_if{ |e| weights[e].nil? }
        weighted_lub = lub.map{ |e| e * weights[e] }

        if variable.nil?
          # Compute the theoretical bounds of the weighted sum. This is slightly
          # sloppy since we could also use the contents of the greatest lower 
          # bound.
          min = weighted_lub.find_all{ |e| e < 0}.inject(0){ |x, y| x + y }
          max = weighted_lub.find_all{ |e| e > 0}.inject(0){ |x, y| x + y }
          variable = @model.int_var(min..max)
        end

        Gecode::Raw::weights(@model.active_space, lub, weighted_lub, set.bind, 
          variable.bind)
        return variable
      end
    end
  end
end