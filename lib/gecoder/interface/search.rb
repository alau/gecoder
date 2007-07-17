module Gecode
  class Model
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
    
    # Finds the optimal solution. Optimality is defined by the provided block
    # which is given one parameter, a solution to the problem. The block should
    # constrain the solution so that that only "better" solutions can be new 
    # solutions. For instance if one wants to optimize a variable named price
    # (accessible from the model) to be as low as possible then one should write
    # the following.
    #
    # model.optimize! do |model, best_so_far|
    #   model.price.must < best_so_far.price.val
    # end
    #
    # Returns nil if there is no solution.
    def optimize!(&block)
      next_space = nil
      best_space = nil
      bab = bab_engine
      
      Model.constrain_proc = lambda do |home_space, best_space|
        @active_space = best_space
        yield(self, self)
        @active_space = home_space
        perform_queued_gecode_interactions
      end
      
      while not (next_space = bab.next).nil?
        best_space = next_space
      end
      Model.constrain_proc = nil
      return nil if best_space.nil?
      return self
    end
    
    class <<self
      def constrain_proc=(proc)
        @constrain_proc = proc
      end
    
      def constrain(home, best)
        if @constrain_proc.nil?
          raise NotImplementedError, 'Constrain method not implemented.' 
        else
          @constrain_proc.call(home, best)
        end
      end
    end
    
    private
    
    # Creates a depth first search engine for search, executing any 
    # unexecuted constraints first.
    def dfs_engine
      # Execute constraints.
      perform_queued_gecode_interactions
      
      # Construct the engine.
      stop = Gecode::Raw::Search::Stop.new
      Gecode::Raw::DFS.new(selected_space, 
        Gecode::Raw::Search::Config::MINIMAL_DISTANCE,
        Gecode::Raw::Search::Config::ADAPTIVE_DISTANCE, 
        stop)
    end
    
    # Creates a branch and bound engine for optimization search, executing any 
    # unexecuted constraints first.
    def bab_engine
      # Execute constraints.
      perform_queued_gecode_interactions
      
      # Construct the engine.
      stop = Gecode::Raw::Search::Stop.new
      Gecode::Raw::BAB.new(selected_space, 
        Gecode::Raw::Search::Config::MINIMAL_DISTANCE,
        Gecode::Raw::Search::Config::ADAPTIVE_DISTANCE, 
        stop)
    end
    
    # Executes any interactions with Gecode still waiting in the queue 
    # (emptying the queue) in the process.
    def perform_queued_gecode_interactions
      allow_space_access do
        gecode_interaction_queue.each{ |con| con.call }
        gecode_interaction_queue.clear # Empty the queue.
      end
    end
  end
end
