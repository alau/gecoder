# This file adds a small layer on top of the bindings. It alters the allocation 
# of variables so that a single array is allocated in each space which is then 
# used to store variable. The variables themselves are not directly returned, 
# rather they are represented as the index in that store, which allows the 
# variable to be retrieved back given a space.
#
# This layer should be moved to the C++ side instead when possible for better
# performance.
module Gecode::Raw
  class Space
    # Creates the specified number of integer variables in the store. Returns
    # the indices with which they can then be accessed using int_var.
    def new_int_vars(min, max, count = 1)
      int_var_store.new_vars(min, max, count)
    end
    
    # Gets the int variable with the specified index, nil if none exists.
    def int_var(index)
      int_var_store[index]
    end
    
    private
    
    # Retrieves the store used for integer variables. Creates one if none
    # exists.
    def int_var_store
      if @int_var_store.nil?
        @int_var_store = Gecode::Raw::IntVarStore.new(self) 
      end
      return @int_var_store
    end
  end

  # A store in which int variables are created and stored.
  class IntVarStore
    # Design note: The store used to double its size when it needed to grow
    # leaving unallocated slots (in rev 16). This was changed to only growing
    # the amount of space needed because the additional information about which
    # slot is the next unallocated one could not be encoded without changes to
    # the bindings (and without that information we can not deduce the store
    # from the new copy of space). So for additional performance the bindings 
    # should grow the array more than needed (when this is moved to the bindings).
    
    private
  
    # A string that identifies the array used by the store.
    ARRAY_IDENTIFIER = 'int_array'
  
    public
    
    # Creates a store for the specified space with the specified capacit.
    def initialize(space)
      @var_array = space.int_var_array(ARRAY_IDENTIFIER)
      if @var_array.nil?
        # Create a new one.
        @var_array = Gecode::Raw::IntVarArray.new(space, 0)
        space.own(@var_array, ARRAY_IDENTIFIER)
      end

      @size = @var_array.size
      @next_index = @size
      @space = space
    end
    
    # Creates the specified number of new int variables with the specified
    # range as domain. Returns the indices of the created variables as an array.
    def new_vars(min, max, count = 1)
      grow(@next_index + count) # See the design note for more information.
      count.times do |i|
        @var_array[@next_index] = Gecode::Raw::IntVar.new(@space, 
          min, max)
        @next_index += 1
      end
      
      ((@next_index - count)...@next_index).to_a
    end

    # Returns the int var with the specified index, nil if none exists.
    def [](index)
      if index < 0 or index >= @next_index
        return nil
      end
      return @var_array.at(index)
    end

    private
    
    # Grows the store to the new size.
    def grow(new_size)
      if new_size <= @size
        raise ArgumentError, 'New size must be larger than the old one.'
      end
      
      new_array = Gecode::Raw::IntVarArray.new(@space, new_size)
      @var_array.size.times do |i|
        new_array[i] = @var_array[i]
      end
      @space.own(new_array, ARRAY_IDENTIFIER)
      @var_array = new_array
      @size = new_size
    end
  end
  
  class IntVar
    # Aliases to make method-names more ruby-like.
    alias_method :assigned?, :assigned
    alias_method :in?, :in
    alias_method :range?, :range
  end
end

