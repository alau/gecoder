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
    
    # Creates a set variable with the specified domain for greatest lower bound
    # and least upper bound (specified as either a range or enum). A range for
    # the allowed cardinality of the set can also be specified, if none is 
    # specified, or nil is given, then the default range (anything) will be 
    # used. If only a single Fixnum is specified as cardinality_range then it's
    # used as lower bound.
    def set_var(glb_domain, lub_domain, cardinality_range = nil)
      check_set_bounds(glb_domain, lub_domain)
      
      index = active_space.new_set_vars(glb_domain, lub_domain, 
        to_set_cardinality_range(cardinality_range)).first
      FreeSetVar.new(self, index)
    end
    
    # Creates an array containing the specified number of set variables. The
    # parameters beyond count are the same as for #set_var .
    def set_var_array(count, glb_domain, lub_domain, cardinality_range = nil)
      check_set_bounds(glb_domain, lub_domain)
      
      variables = []
      active_space.new_set_vars(glb_domain, lub_domain, 
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
      
      indices = active_space.new_set_vars(glb_domain, lub_domain, 
        to_set_cardinality_range(cardinality_range), row_count*col_count)
      rows = []
      row_count.times do |i|
        rows << indices[(i*col_count)...(i.succ*col_count)].map! do |index|
          FreeSetVar.new(self, index)
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
    
    # Transforms the argument to a set cardinality range, returns nil if the
    # default range should be used. If arg is a range then that's used, 
    # otherwise if the argument is a fixnum it's used as lower bound.
    def to_set_cardinality_range(arg)
      if arg.kind_of? Fixnum
        arg..Gecode::Raw::Limits::Set::CARD_MAX
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
      if glb.kind_of?(Range) and lub.kind_of?(Range)
        glb.first >= lub.first and glb.last <= lub.last
      else
        (glb.to_a - lub.to_a).empty?
      end
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