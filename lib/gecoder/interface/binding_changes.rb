# This file adds a small layer on top of the bindings. It alters the allocation 
# of variables so that a single array is allocated in each space which is then 
# used to store variable. The variables themselves are not directly returned, 
# rather they are represented as the index in that store, which allows the 
# variable to be retrieved back given a space.
#
# This layer should be moved to the C++ side instead when possible for better
# performance.
module Gecode
  module Raw
    class Space
      # Creates the specified number of integer variables in the space. Returns
      # the indices with which they can then be accessed using int_var.
      def new_int_vars(min, max, count = 1)
        int_var_store.new_vars(min, max, count)
      end
      
      # Gets the int variable with the specified index, nil if none exists.
      def int_var(index)
        int_var_store[index]
      end
      
      # Creates the specified number of boolean variables in the space. Returns
      # the indices with which they can then be accessed using bool_var.
      def new_bool_vars(count = 1)
        bool_var_store.new_vars(count)
      end
      
      # Gets the bool variable with the specified index, nil if none exists.
      def bool_var(index)
        bool_var_store[index]
      end
      
      # Creates the specified number of set variables in the space. Returns
      # the indices with which they can then be accessed using set_var.
      def new_set_vars(glb_min, glb_max, lub_min, lub_max, count = 1)
        set_var_store.new_vars(glb_min, glb_max, lub_min, lub_max, count)
      end
      
      # Gets the set variable with the specified index, nil if none exists.
      def set_var(index)
        set_var_store[index]
      end
      
      private
      
      # Retrieves the store used for integer variables. Creates one if none
      # exists.
      def int_var_store
        if @int_var_store.nil?
          @int_var_store = Gecode::Util::IntVarStore.new(self) 
        end
        return @int_var_store
      end
      
      # Retrieves the store used for boolean variables. Creates one if none
      # exists.
      def bool_var_store
        if @bool_var_store.nil?
          @bool_var_store = Gecode::Util::BoolVarStore.new(self) 
        end
        return @bool_var_store
      end
      
      # Retrieves the store used for set variables. Creates one if none exists.
      def set_var_store
        if @set_var_store.nil?
          @set_var_store = Gecode::Util::SetVarStore.new(self) 
        end
        return @set_var_store
      end
    end
    
    class IntVar
      # Aliases to make method-names more ruby-like.
      alias_method :assigned?, :assigned
      alias_method :in?, :in
      alias_method :include?, :in
      alias_method :range?, :range
    end
    
    class BoolVar
      # Aliases to make method-names more ruby-like.
      alias_method :assigned?, :assigned
      
      def true?
        val == 1
      end
      
      def false?
        val == 0
      end
    end
    
    class SetVar
      # Aliases to make method-names more ruby-like.
      alias_method :assigned?, :assigned
      alias_method :constains?, :contains
      alias_method :lub_min, :lubMin
      alias_method :glb_max, :lubMax
      alias_method :glb_min, :glbMin
      alias_method :glb_max, :glbMax
    end
  end
  
  # Various utility (mainly used to change the behavior of the raw bindings).
  module Util
    # Provides common methods to the variable stores. The stores must provide
    # @next_index, @var_array, @size, ARRAY_IDENTIFIER and #new_storage_array .
    module VarStoreMethods
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
        new_array = new_storage_array(new_size)
        @var_array.size.times do |i|
          new_array[i] = @var_array[i]
        end
        @var_array = new_array
        @size = new_size
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
      
      include VarStoreMethods
      
      private
    
      # A string that identifies the array used by the store.
      ARRAY_IDENTIFIER = 'int_array'
    
      public
      
      # Creates a store for the specified space with the specified capacit.
      def initialize(space)
        @space = space
        
        @var_array = space.int_var_array(ARRAY_IDENTIFIER)
        if @var_array.nil?
          # Create a new one.
          @var_array = new_storage_array(0)
        end
  
        @size = @var_array.size
        @next_index = @size
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
      
      # Creates a new storage array for int variables.
      def new_storage_array(new_size)
        arr = Gecode::Raw::IntVarArray.new(@space, new_size)
        @space.own(arr, ARRAY_IDENTIFIER)
        return arr
      end
    end
    
    # A store in which int variables are created and stored.
    class BoolVarStore
      # TODO: can we refactor this better seeing as IntVarStore and BoolVarStore
      # are similar?
      
      include VarStoreMethods
      
      private
    
      # A string that identifies the array used by the store.
      ARRAY_IDENTIFIER = 'bool_array'
    
      public
      
      # Creates a store for the specified space with the specified capacit.
      def initialize(space)
        @space = space
      
        @var_array = space.bool_var_array(ARRAY_IDENTIFIER)
        if @var_array.nil?
          # Create a new one.
          @var_array = new_storage_array(0)
        end
  
        @size = @var_array.size
        @next_index = @size
      end
      
      # Creates the specified number of new bool variables. Returns the indices 
      # of the created variables as an array.
      def new_vars(count = 1)
        grow(@next_index + count) # See the design note for more information.
        count.times do |i|
          @var_array[@next_index] = Gecode::Raw::BoolVar.new(@space, 0, 1)
          @next_index += 1
        end
        
        ((@next_index - count)...@next_index).to_a
      end
  
      private
      
      # Creates a new storage array for bool variables.
      def new_storage_array(new_size)
        arr = Gecode::Raw::BoolVarArray.new(@space, new_size)
        @space.own(arr, ARRAY_IDENTIFIER)
        return arr
      end
    end
    
    # A store in which int variables are created and stored.
    class SetVarStore
      include VarStoreMethods
      
      private
    
      # A string that identifies the array used by the store.
      ARRAY_IDENTIFIER = 'set_array'
    
      public
      
      # Creates a store for the specified space with the specified capacit.
      def initialize(space)
        @space = space
      
        @var_array = space.set_var_array(ARRAY_IDENTIFIER)
        if @var_array.nil?
          # Create a new one.
          @var_array = new_storage_array(0)
        end
  
        @size = @var_array.size
        @next_index = @size
      end
      
      # Creates the specified number of new bool variables. Returns the indices 
      # of the created variables as an array.
      def new_vars(glb_min, glb_max, lub_min, lub_max, count = 1)
        grow(@next_index + count) # See the design note for more information.
        count.times do |i|
          @var_array[@next_index] = Gecode::Raw::SetVar.new(@space, glb_min, 
            glb_max, lub_min, lub_max, 0, Gecode::Raw::Limits::Set::CARD_MAX)
          @next_index += 1
        end
        
        ((@next_index - count)...@next_index).to_a
      end
  
      private
      
      # Creates a new storage array for bool variables.
      def new_storage_array(new_size)
        arr = Gecode::Raw::SetVarArray.new(@space, new_size)
        @space.own(arr, ARRAY_IDENTIFIER)
        return arr
      end
    end
  end
end
