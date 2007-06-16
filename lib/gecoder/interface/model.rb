module Gecode
  # Model is the base class that all models must inherit from. The superclass
  # constructor must be called.
  class Model
    # Design notes: Only one model per problem is used. A model has multiple 
    # spaces. A model has a base space in which it sets up during the 
    # initialization. The model binds the int variables to the current space 
    # upon use.
  
    # The base from which searches are made. 
    attr :base_space
    # The currently active space (the one which variables refer to).
    attr_accessor :active_space
    protected :active_space=
    
    def initialize
      @active_space = @base_space = Gecode::Raw::Space.new
    end
    
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
        if element.respond_to? :begin and element.respond_to? :end
          min = element.begin
          max = element.end
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
        # arguments as domain.
        # TODO: use the model's way of defining domain constraints when 
        # available.
        domain_set = Gecode::Raw::IntSet.new(domain_args, domain_args.size)
        Gecode::Raw::dom(active_space, var.bind, domain_set, 
          Gecode::Raw::ICL_DEF)
      end
      return var
    end
  end
  
  # An IntVar that is bound to a model, but not to a particular space.  
  class FreeIntVar
    attr_accessor :model
  
    # Creates an int variable with the specified index.
    def initialize(model, index)
      @model = model
      @index = index
      @bound_space = @bound_var = nil
    end
    
    # Delegate methods we can't handle to the bound int variable if possible.
    def method_missing(name, *args)
      if Gecode::Raw::IntVar.instance_methods.include? name.to_s
        bind.send(name, *args)
      else
        super
      end
    end
    
    # Binds the int variable to the currently active space of the model, 
    # returning the bound int variable.
    def bind
      space = active_space
      unless @bound_space == space
        # We have not bound the variable to this space, so we do it now.
        @bound = space.int_var(@index)
        @bound_space = space
      end
      return @bound
    end
    
    private
    
    # Returns the space that the int variable should bind to when needed.
    def active_space
      @model.active_space
    end
  end
end