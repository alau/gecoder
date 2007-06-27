module Gecode
  # Model is the base class that all models must inherit from.
  class Model
    attr :constraints
    protected :constraints
  
    # Creates a new integer variable with the specified domain. The domain can
    # either be a range or a number of elements. 
    def int_var(*domain_args)
      range = domain_range(*domain_args)
      index = active_space.new_int_vars(range.begin, range.end).first
      construct_int_var(index, *domain_args)
    end
    
    # Creates an array containing the specified number of integer variables 
    # with the specified domain. The domain can either be a range or a number 
    # of elements. 
    def int_var_array(count, *domain_args)
      # TODO: Maybe the custom domain should be specified as an array instead? 
      
      range = domain_range(*domain_args)
      variables = []
      active_space.new_int_vars(range.begin, range.end, count).each do |index|
        variables << construct_int_var(index, *domain_args)
      end
      return wrap_enum(variables)
    end
    
    # Creates a matrix containing the specified number rows and columns of 
    # integer variables with the specified domain. The domain can either be a 
    # range or a number of elements. 
    def int_var_matrix(row_count, col_count, *domain_args)
      # TODO: Maybe the custom domain should be specified as an array instead? 
      
      range = domain_range(*domain_args)
      indices = active_space.new_int_vars(range.begin, range.end, 
        row_count*col_count)
      rows = []
      row_count.times do |i|
        rows << indices[(i*col_count)...(i.succ*col_count)].map! do |index|
          construct_int_var(index, *domain_args)
        end
      end
      return wrap_enum(Util::EnumMatrix.rows(rows, false))
    end
    
    # Creates a new boolean variable.
    def bool_var(*domain_args)
      index = active_space.new_bool_vars.first
      FreeBoolVar.new(self, index)
    end
    
    # Creates an array containing the specified number of boolean variables.
    def bool_var_array(count)
      variables = []
      active_space.new_bool_vars(count).each do |index|
        variables << FreeBoolVar.new(self, index)
      end
      return wrap_enum(variables)
    end
    
    # Creates a matrix containing the specified number rows and columns of 
    # boolean variables.
    def bool_var_matrix(row_count, col_count)
      indices = active_space.new_bool_vars(row_count*col_count)
      rows = []
      row_count.times do |i|
        rows << indices[(i*col_count)...(i.succ*col_count)].map! do |index|
          FreeBoolVar.new(self, index)
        end
      end
      return wrap_enum(Util::EnumMatrix.rows(rows, false))
    end
    
    # Retrieves the currently active space (the one which variables refer to).
    def active_space
      @active_space ||= base_space
    end
    
    # Retrieves the base from which searches are made. 
    def base_space
      @base_space ||= Gecode::Raw::Space.new
    end
    
    # Adds the specified constraint to the model. Returns the newly added 
    # constraint.
    def add_constraint(constraint)
      constraints << constraint
      return constraint
    end
    
    protected
    
    def constraints
      @constraints ||= []
    end
    
    private
    
    # Returns the range of the specified domain arguments, which can either be
    # given as a range or a number of elements. Raises ArgumentError if no 
    # arguments have been specified. 
    def domain_range(*domain_args)
      min = max = nil
      if domain_args.empty?
        raise ArgumentError, 'A domain has to be specified.'
      elsif domain_args.size > 1
        min = domain_args.min
        max = domain_args.max
      else
        element = domain_args.first
        if element.respond_to?(:begin) and element.respond_to?(:end) and
            element.respond_to?(:exclude_end?)
          min = element.begin
          max = element.end
          max -= 1 if element.exclude_end?
        else
          min = max = element
        end
      end
      return min..max
    end
    
    # Creates an integer variable from the specified index and domain. The 
    # domain can either be given as a range or as a number of elements.
    def construct_int_var(index, *domain_args)
      var = FreeIntVar.new(self, index)
      
      if domain_args.size > 1
        # Place an additional domain constraint on the variable with the 
        # arguments as domain. We post it directly since there's no reason not
        # to and the user might otherwise get unexpected domains when inspecting
        # the variable before solving.
        constraint = var.must_be.in domain_args
        @constraints.delete(constraint).post
      end
      return var
    end
  end
end