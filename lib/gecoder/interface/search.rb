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
      dfs = Gecode::Raw::DFS.new(@base_space, COPY_DIST, ADAPTATION_DIST, stop)
      space = dfs.next
      return nil if space.nil?
      @active_space = space
      return self
    end
  end
end
