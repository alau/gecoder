module Gecode
  # Model is the base class that all models must inherit from.
  class Model
    # The largest integer allowed in the domain of an integer variable.
    MAX_INT = Gecode::Raw::IntLimits::MAX
    # The smallest integer allowed in the domain of an integer variable.
    MIN_INT = Gecode::Raw::IntLimits::MIN

    # The largest integer allowed in the domain of a set variable.
    SET_MAX_INT = Gecode::Raw::SetLimits::MAX
    # The smallest integer allowed in the domain of a set variable.
    SET_MIN_INT = Gecode::Raw::SetLimits::MIN

    # The largest possible domain for an integer variable.
    LARGEST_INT_DOMAIN = MIN_INT..MAX_INT
    # The largest possible domain, without negative integers, for an
    # integer variable.
    NON_NEGATIVE_INT_DOMAIN = 0..MAX_INT

    # The largest possible bound for a set variable.
    LARGEST_SET_BOUND = SET_MIN_INT..SET_MAX_INT

    # Creates a new integer variable with the specified domain. The domain can
    # either be a range, a single element, or an enumeration of elements. If no
    # domain is specified then the largest possible domain is used.
    def int_var(domain = LARGEST_INT_DOMAIN)
      args = domain_arguments(domain)
      FreeIntVar.new(self, variable_creation_space.new_int_var(*args))
    end
    
    # Creates an array containing the specified number of integer variables 
    # with the specified domain. The domain can either be a range, a single 
    # element, or an enumeration of elements. If no domain is specified then 
    # the largest possible domain is used.
    def int_var_array(count, domain = LARGEST_INT_DOMAIN)
      args = domain_arguments(domain)
      build_var_array(count) do
        FreeIntVar.new(self, variable_creation_space.new_int_var(*args))
      end
    end
    
    # Creates a matrix containing the specified number rows and columns of 
    # integer variables with the specified domain. The domain can either be a 
    # range, a single element, or an enumeration of elements. If no domain 
    # is specified then the largest possible domain is used.
    def int_var_matrix(row_count, col_count, domain = LARGEST_INT_DOMAIN)
      args = domain_arguments(domain)
      build_var_matrix(row_count, col_count) do
        FreeIntVar.new(self, variable_creation_space.new_int_var(*args))
      end
    end
    
    # Creates a new boolean variable.
    def bool_var
      FreeBoolVar.new(self, variable_creation_space.new_bool_var)
    end
    
    # Creates an array containing the specified number of boolean variables.
    def bool_var_array(count)
      build_var_array(count) do
        FreeBoolVar.new(self, variable_creation_space.new_bool_var)
      end
    end
    
    # Creates a matrix containing the specified number rows and columns of 
    # boolean variables.
    def bool_var_matrix(row_count, col_count)
      build_var_matrix(row_count, col_count) do
        FreeBoolVar.new(self, variable_creation_space.new_bool_var)
      end
    end
    
    # Creates a set variable with the specified domain for greatest lower bound
    # and least upper bound (specified as either a fixnum, range or enum). If 
    # no bounds are specified then the empty set is used as greatest lower 
    # bound and the largest possible set as least upper bound. 
    #
    # A range for the allowed cardinality of the set can also be
    # specified, if none is specified, or nil is given, then the default
    # range (anything) will be used. If only a single Fixnum is
    # specified as cardinality_range then it's used as lower bound.
    def set_var(glb_domain = [], lub_domain = LARGEST_SET_BOUND,
        cardinality_range = nil)
      args = set_bounds_to_parameters(glb_domain, lub_domain, cardinality_range)
      FreeSetVar.new(self, variable_creation_space.new_set_var(*args))
    end
    
    # Creates an array containing the specified number of set variables. The
    # parameters beyond count are the same as for #set_var .
    def set_var_array(count, glb_domain = [], lub_domain = LARGEST_SET_BOUND, 
        cardinality_range = nil)
      args = set_bounds_to_parameters(glb_domain, lub_domain, cardinality_range)
      build_var_array(count) do
        FreeSetVar.new(self, variable_creation_space.new_set_var(*args))
      end
    end
    
    # Creates a matrix containing the specified number of rows and columns 
    # filled with set variables. The parameters beyond row and column counts are
    # the same as for #set_var .
    def set_var_matrix(row_count, col_count, glb_domain = [], 
        lub_domain = LARGEST_SET_BOUND, cardinality_range = nil)
      args = set_bounds_to_parameters(glb_domain, lub_domain, cardinality_range)
      build_var_matrix(row_count, col_count) do
        FreeSetVar.new(self, variable_creation_space.new_set_var(*args))
      end
    end
    
    # Retrieves the currently used space. Calling this method is only allowed 
    # when sanctioned by the model beforehand, e.g. when the model asks a 
    # constraint to post itself. Otherwise an RuntimeError is raised.
    #
    # The space returned by this method should never be stored, it should be
    # rerequested from the model every time that it's needed.
    def active_space #:nodoc:
      unless @allow_space_access
        raise 'Space access is restricted and the permission to access the ' + 
          'space has not been given.'
      end
      selected_space
    end
    
    # Adds the specified constraint to the model. Returns the newly added 
    # constraint.
    def add_constraint(constraint) #:nodoc:
      add_interaction do
        constraint.post
      end
      return constraint
    end
    
    # Adds a block containing something that interacts with Gecode to a queue
    # where it is potentially executed.
    def add_interaction(&block) #:nodoc:
      gecode_interaction_queue << block
    end
    
    # Allows the model's active space to be accessed while the block is 
    # executed. Don't use this unless you know what you're doing. Anything that
    # the space is used for (such as bound variables) must be released before
    # the block ends.
    #
    # Returns the result of the block.
    def allow_space_access(&block) #:nodoc:
      # We store the old value so that nested calls don't become a problem, i.e.
      # access is allowed as long as one call to this method is still on the 
      # stack.
      old = @allow_space_access
      @allow_space_access = true
      res = yield
      @allow_space_access = old
      return res
    end
    
    # Starts tracking a variable that depends on the space. All variables 
    # created should call this method for their respective models.
    def track_variable(variable) #:nodoc:
      (@variables ||= []) << variable
    end

    # Wraps method to handle #foo_is_a and #foo_is_an .
    def method_missing(name_symbol, *args)
      name = name_symbol.to_s
      if name =~ /._is_an?$/
        name.sub!(/_is_an?$/, '')
        unless args.size == 1
          raise ArgumentError, "Wrong number of argmuments (#{args.size} for 1)."
        end 

        # We use the meta class to avoid defining the variable in all
        # other instances of the class.
        eval <<-"end_eval"
          @#{name} = args.first
          class <<self
            attr :#{name}
          end
        end_eval
      else
        super
      end
    end

    protected
    
    # Gets a queue of objects that can be posted to the model's active_space 
    # (by calling their post method).
    def gecode_interaction_queue #:nodoc:
      @gecode_interaction_queue ||= []
    end
    
    private
    
    # Creates an array containing the specified number of variables, all
    # constructed using the provided block..
    def build_var_array(count, &block)
      variables = []
      count.times do 
        variables << yield
      end
      return wrap_enum(variables)
    end
    
    # Creates a matrix containing the specified number rows and columns of 
    # variables, all constructed using the provided block. 
    def build_var_matrix(row_count, col_count, &block)
      rows = []
      row_count.times do |i|
        row = []
        col_count.times do |j|
          row << yield
        end
        rows << row
      end
      return wrap_enum(Util::EnumMatrix.rows(rows, false))
    end

    # Returns the array of arguments that correspond to the specified 
    # domain when given to Gecode. The domain can be given as a range, 
    # a single number, or an enumerable of elements. 
    def domain_arguments(domain)
      if domain.respond_to?(:first) and domain.respond_to?(:last) and
            domain.respond_to?(:exclude_end?)
        if domain.exclude_end?
          return [domain.first, (domain.last - 1)]
        else
          return [domain.first, domain.last]
        end
      elsif domain.kind_of? Enumerable
        array = domain.to_a
        return [Gecode::Raw::IntSet.new(array, array.size)]
      elsif domain.kind_of? Fixnum
        return [domain, domain]
      else
        raise TypeError, 'The domain must be given as an instance of ' +
          "Enumerable or Fixnum, but #{domain.class} was given."
      end
    end
    
    # Transforms the argument to a set cardinality range, returns nil if the
    # default range should be used. If arg is a range then that's used, 
    # otherwise if the argument is a fixnum it's used as lower bound.
    def to_set_cardinality_range(arg)
      if arg.kind_of? Fixnum
        arg..Gecode::Raw::SetLimits::MAX
      else
        arg
      end
    end
    
    # Converts the specified set var domain to parameters accepted by
    # Gecode. The bounds can be specified as a fixnum, range or # enum. 
    # The parameters are returned as an array.
    def set_bounds_to_parameters(glb_domain, lub_domain, cardinality_range)
      check_set_bounds(glb_domain, lub_domain)
      args = []
      args << Gecode::Constraints::Util.constant_set_to_int_set(glb_domain)
      args << Gecode::Constraints::Util.constant_set_to_int_set(lub_domain)
      card_range = to_set_cardinality_range(cardinality_range)
      if card_range.nil?
        card_range = 0..Gecode::Raw::SetLimits::CARD
      end
      args << card_range.first << card_range.last
    end
    
    # Checks whether the specified greatest lower bound is a subset of least 
    # upper bound. Raises ArgumentError if that is not the case.
    def check_set_bounds(glb, lub)
      unless valid_set_bounds?(glb, lub)
        raise ArgumentError, 
          "Invalid set bounds: #{glb} is not a subset of #{lub}."
      end
    end
    
    # Returns whether the greatest lower bound is a subset of least upper 
    # bound.
    def valid_set_bounds?(glb, lub)
      return true if glb.respond_to?(:empty?) and glb.empty? 
      if glb.kind_of?(Range) and lub.kind_of?(Range)
        glb.first >= lub.first and glb.last <= lub.last
      else
        glb = [glb] if glb.kind_of?(Fixnum)
        lub = [lub] if lub.kind_of?(Fixnum)
        (glb.to_a - lub.to_a).empty?
      end
    end
    
    # Retrieves the base from which searches are made. 
    def base_space
      @base_space ||= Gecode::Raw::Space.new
    end
    
    # Retrieves the currently selected space, the one which constraints and 
    # variables should be bound to.
    def selected_space
      return @active_space unless @active_space.nil?
      self.active_space = base_space
    end
    
    # Retrieves the space that should be used for variable creation.
    def variable_creation_space
      @variable_creation_space || selected_space
    end
    
    # Executes any interactions with Gecode still waiting in the queue 
    # (emptying the queue) in the process.
    def perform_queued_gecode_interactions
      allow_space_access do
        gecode_interaction_queue.each{ |con| con.call }
        gecode_interaction_queue.clear # Empty the queue.
      end
    end
    
    # Switches the active space used (the space from which variables are read
    # and to which constraints are posted). @active_space should never be 
    # assigned directly.
    def active_space=(new_space)
      @active_space = new_space
    end    
  end
end
