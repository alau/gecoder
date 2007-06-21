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
      stop = Gecode::Raw::Search::Stop.new
      dfs = Gecode::Raw::DFS.new(active_space, COPY_DIST, ADAPTATION_DIST, stop)
      space = dfs.next
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
  end
end
