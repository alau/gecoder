module Gecode
  class Model
    private
    
    # Used during the search.
    COPY_DIST = 16
    ADAPTATION_DIST = 4 
    
    public
    
    def initialize_copy(other)
      super
    
      instance_variables.each do |var|
        # Copy all int variables and update their model.
        if instance_eval(var).kind_of? FreeIntVar
          instance_eval <<-"end_code"
            #{var} = #{var}.clone
            #{var}.model = self
          end_code
        end
        
        # Copy all int enums and update their model.
        if instance_eval(var).kind_of? IntEnumConstraintMethods
          instance_eval <<-"end_code"
            #{var} = #{var}.clone
            #{var}.model = self
          end_code
        end
      end
    end
    
    # Finds the first solution to the modelled problem and returns it. Returns
    # nil if there was no solution.
    def solution
      stop = Gecode::Raw::Search::Stop.new
      dfs = Gecode::Raw::DFS.new(@base_space, COPY_DIST, ADAPTATION_DIST, stop)

      space = dfs.next
      if space.nil?
        nil
      else
        # Make a shallow copy and alter the active space.
        copy = self.clone
        copy.active_space = space
        return copy
      end
    end
  end
end