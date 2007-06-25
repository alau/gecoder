module Gecode
  class Model
    private
    
    # Used during the search.
    COPY_DIST = 16
    ADAPTATION_DIST = 4 
    
    public

    # Finds the first solution to the modelled problem and updates the variables
    # to that solution. Returns the model if a solution was found, nil 
    # otherwise.
    def solve!
      space = dfs_engine.next
      return nil if space.nil?
      @active_space = space
      return self
    end
    
    # Returns to the original state, before any search was made (but propagation 
    # might have been performed). Returns the reset model.
    def reset!
      @active_space = base_space
      return self
    end
    
    # Yields the first solution (if any) to the block. If no solution is found
    # then the block is not used. Returns the result of the block (nil in case
    # the block wasn't run). 
    def solution(&block)
      solution = self.solve!
      res = yield solution unless solution.nil?
      self.reset!
      return res
    end
    
    # Yields each solution that the model has.
    def each_solution(&block)
      dfs = dfs_engine
      while not (@active_space = dfs.next).nil?
        yield self
      end
      self.reset!
    end
    
    private
    
    # Creates an DFS engine for the search, executing any unexecuted 
    # constraints first.
    def dfs_engine
      # Execute constraints.
      constraints.each{ |con| con.post }
      constraints.clear # Empty the queue.
    
      stop = Gecode::Raw::Search::Stop.new
      Gecode::Raw::DFS.new(active_space, COPY_DIST, ADAPTATION_DIST, stop)
    end
  end
end
