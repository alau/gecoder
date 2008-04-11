module Gecode
  # Model is the base class that all models must inherit from.
  class Model
    # Creates a new integer variable with the specified domain. The domain can
    # either be a range, a single element, or an enumeration of elements. If no
    # domain is specified then the largest possible domain is used.
    def int_var(domain = 
        Gecode::Raw::IntLimits::MIN..Gecode::Raw::IntLimits::MAX)
      enum = domain_enum(domain)
      index = variable_creation_space.new_int_vars(enum).first
      FreeIntVar.new(self, index)
    end
    
    # Creates an array containing the specified number of integer variables 
    # with the specified domain. The domain can either be a range, a single 
    # element, or an enumeration of elements. 
    def int_var_array(count, domain)
      enum = domain_enum(domain)
      variables = []
      variable_creation_space.new_int_vars(enum, count).each do |index|
        variables << FreeIntVar.new(self, index)
      end
      return wrap_enum(variables)
    end
    
    # Creates a matrix containing the specified number rows and columns of 
    # integer variables with the specified domain. The domain can either be a 
    # range, a single element, or an enumeration of elements. 
    def int_var_matrix(row_count, col_count, domain)
      enum = domain_enum(domain)
      indices = variable_creation_space.new_int_vars(enum, row_count*col_count)
      rows = []
      row_count.times do |i|
        rows << indices[(i*col_count)...(i.succ*col_count)].map! do |index|
          FreeIntVar.new(self, index)
        end
      end
      return wrap_enum(Util::EnumMatrix.rows(rows, false))
    end
    
    # Creates a new boolean variable.
    def bool_var
      index = variable_creation_space.new_bool_vars.first
      FreeBoolVar.new(self, index)
    end
    
    # Creates an array containing the specified number of boolean variables.
    def bool_var_array(count)
      variables = []
      variable_creation_space.new_bool_vars(count).each do |index|
        variables << FreeBoolVar.new(self, index)
      end
      return wrap_enum(variables)
    end
    
    # Creates a matrix containing the specified number rows and columns of 
    # boolean variables.
    def bool_var_matrix(row_count, col_count)
      indices = variable_creation_space.new_bool_vars(row_count*col_count)
      rows = []
      row_count.times do |i|
        rows << indices[(i*col_count)...(i.succ*col_count)].map! do |index|
          FreeBoolVar.new(self, index)
        end
      end
      return wrap_enum(Util::EnumMatrix.rows(rows, false))
    end
    
    # Creates a set variable with the specified domain for greatest lower bound
    # and least upper bound (specified as either a fixnum, range or enum). If 
    # no bounds are specified then the empty set is used as greates lower bound 
    # and the universe as least upper bound. A range for the allowed cardinality
    # of the set can also be specified, if none is specified, or nil is given, 
    # then the default range (anything) will be used. If only a single Fixnum is 
    # specified as cardinality_range then it's used as lower bound.
    def set_var(glb_domain = [], lub_domain = 
        Gecode::Raw::SetLimits::MIN..Gecode::Raw::SetLimits::MAX, 
        cardinality_range = nil)
      check_set_bounds(glb_domain, lub_domain)
      
      index = variable_creation_space.new_set_vars(glb_domain, lub_domain, 
        to_set_cardinality_range(cardinality_range)).first
      FreeSetVar.new(self, index)
    end
    
    # Creates an array containing the specified number of set variables. The
    # parameters beyond count are the same as for #set_var .
    def set_var_array(count, glb_domain, lub_domain, cardinality_range = nil)
      check_set_bounds(glb_domain, lub_domain)
      
      variables = []
      variable_creation_space.new_set_vars(glb_domain, lub_domain, 
          to_set_cardinality_range(cardinality_range), count).each do |index|
        variables << FreeSetVar.new(self, index)
      end
      return wrap_enum(variables)
    end
    
    # Creates a matrix containing the specified number of rows and columns 
    # filled with set variables. The parameters beyond row and column counts are
    # the same as for #set_var .
    def set_var_matrix(row_count, col_count, glb_domain, lub_domain, 
        cardinality_range = nil)
      check_set_bounds(glb_domain, lub_domain)
      
      indices = variable_creation_space.new_set_vars(glb_domain, lub_domain, 
        to_set_cardinality_range(cardinality_range), row_count*col_count)
      rows = []
      row_count.times do |i|
        rows << indices[(i*col_count)...(i.succ*col_count)].map! do |index|
          FreeSetVar.new(self, index)
        end
      end
      return wrap_enum(Util::EnumMatrix.rows(rows, false))
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
    
    protected
    
    # Gets a queue of objects that can be posted to the model's active_space 
    # (by calling their post method).
    def gecode_interaction_queue #:nodoc:
      @gecode_interaction_queue ||= []
    end
    
    private
    
    # Returns an enumeration of the specified domain arguments, which can 
    # either be given as a range, a single number, or an enumerable of elements. 
    def domain_enum(domain)
      if domain.respond_to?(:first) and domain.respond_to?(:last) and
            domain.respond_to?(:exclude_end?)
        if domain.exclude_end?
          return domain.first..(domain.last - 1)
        else
          return domain
        end
      elsif domain.kind_of? Enumerable
        return domain
      else
        return domain..domain
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
    
    # Refreshes all cached variables. This should be called if the variables
    # in an existing space were changed.
    def refresh_variables
      return if @variables.nil?
      @variables.each do |variable|
        variable.refresh if variable.cached?
      end
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
      new_space.refresh
      refresh_variables
    end    
  end
end