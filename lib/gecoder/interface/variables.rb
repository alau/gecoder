module Gecode
  # Describes a variable that is bound to a model, but not to a particular 
  # space.  
  class FreeVarBase #:nodoc:
    attr_accessor :model
  
    # Creates an int variable with the specified index.
    def initialize(model, index)
      @model = model
      @index = index
      model.track_variable(self)
    end

    def inspect
      if assigned?
        "#<#{self.class} #{domain}>"
      else
        "#<#{self.class} #{domain}>"
      end
    end
    
    private
    
    # Returns the space that the int variable should bind to when needed.
    def active_space
      @model.active_space
    end
    
    # Sends the specified method name and arguments to the bound variable.
    def send_bound(method_name, *args)
      @model.allow_space_access do
        bind.send(method_name, *args)
      end
    end
  end
  
  # Creates a class for a free variable that can be bound into the specified
  # class using the specified method in a space.
  def Gecode::FreeVar(bound_class, space_bind_method)
    clazz = Class.new(FreeVarBase)
    clazz.class_eval <<-"end_method_definitions"      
      # Binds the int variable to the currently active space of the model, 
      # returning the bound int variable.
      def bind
        active_space.method(:#{space_bind_method}).call(@index)
      end
      
      private
      
      # Delegates the method with the specified name to a method with the 
      # specified name when the variable is bound. If the bound method's name
      # is nil then the same name as the new method's name is assumed.
      def self.delegate(method_name, bound_method_name = nil)
        bound_method_name = method_name if bound_method_name.nil?
        module_eval <<-"end_code"
          def \#{method_name}(*args)
            @model.allow_space_access do
              bind.method(:\#{bound_method_name}).call(*args)
            end
          end
        end_code
      end
    end_method_definitions
    return clazz
  end
  
  FreeIntVar = FreeVar(Gecode::Raw::IntVar, :int_var)
  # Describes an integer variable. Each integer variable has a domain of several
  # integers which represent the possible values that the variable may take. 
  # An integer variable is said to be assigned once the domain only contains a
  # single element, at which point #value can be used to retrieve the value.
  class FreeIntVar
    # Gets the minimum value still in the domain of the variable.
    delegate :min
    # Gets the maximum value still in the domain of the variable.
    delegate :max
    # Gets the number of elements still in the domain of the variable.
    delegate :size
    # Gets the width of the variable's domain, i.e. the distance between the
    # maximum and minimum values.
    delegate :width
    # Gets the degree of the variable. The degree is the number of constraints
    # that are affected by the variable. So if the variable is used in two
    # constraints then the value will be 2.
    delegate :degree
    # Checks whether the domain is a range, i.e. doesn't contain any holes.
    delegate :range?, :range
    # Checks whether the variable has been assigned, i.e. its domain only 
    # contains one element.
    delegate :assigned?, :assigned
    # Checks whether a specified integer is in the variable's domain.
    delegate :include?, :in
    
    # Gets the value of the assigned integer variable (a Fixnum). The variable
    # must be assigned, if it isn't then a RuntimeError is raised.
    def value
      raise 'No value is assigned.' unless assigned?
      send_bound(:val)
    end
    
    private
    
    # Returns a string representation of the the range of the variable's domain.
    def domain #:nodoc:
      if assigned?
        "range: #{value.to_s}"
      else
        "range: #{min}..#{max}"
      end
    end
  end
  
  FreeBoolVar = FreeVar(Gecode::Raw::BoolVar, :bool_var)
  # Describes a boolean variable. A boolean variable can be either true or 
  # false.
  class FreeBoolVar
    # Checks whether the variable has been assigned.
    delegate :assigned?, :assigned
    
    # Gets the values in the assigned boolean variable (true or false). The 
    # variable must be assigned, if it isn't then a RuntimeError is raised.
    def value
      raise 'No value is assigned.' unless assigned?
      send_bound(:val) == 1
    end
  
    private
  
    # Returns a string representation of the the variable's domain.
    def domain
      if assigned?
        value.to_s
      else
        'unassigned'
      end
    end
  end

  FreeSetVar = FreeVar(Gecode::Raw::SetVar, :set_var)
  # Describes a set variable. 
  # 
  # A set variable's domain, i.e. possible values that it can take, are 
  # represented with a greatest lower bound (GLB) and a least upper bound (LUB).
  # The set variable may then take any set value S such that S is a subset of
  # the least upper bound and the greatest lower bound is a subset of S.
  #   
  # If for instance the set has a greatest lower bound {1} and least upper bound
  # {1,3,5} then the assigned set may be any of the following four sets: {1}, 
  # {1,3}, {1,5}, {1,3,5}. 
  # 
  # The domain of a set variable may also specify the cardinality of the set, 
  # i.e. the number of elements that the set may contains.
  class FreeSetVar
    # Checks whether the variable has been assigned.
    delegate :assigned?, :assigned
    
    # Gets all the elements located in the greatest lower bound of the set (an 
    # Enumerable).
    def lower_bound
      min = send_bound(:glbMin)
      max = send_bound(:glbMax)
      EnumerableView.new(min, max, send_bound(:glbSize)) do
        (min..max).to_a.delete_if{ |e| not send_bound(:contains, e) }
      end
    end
    
    # Gets all the elements located in the least upper bound of the set (an 
    # Enumerable).
    def upper_bound
      min = send_bound(:lubMin)
      max = send_bound(:lubMax)
      EnumerableView.new(min, max, send_bound(:lubSize)) do
        (min..max).to_a.delete_if{ |e| send_bound(:notContains, e) }
      end
    end
    
    # Gets the values in the assigned set variable (an enumerable).
    def value
      raise 'No value is assigned.' unless assigned?
      lower_bound
    end
    
    # Returns a range containing the allowed values for the set's cardinality.
    def cardinality
      send_bound(:cardMin)..send_bound(:cardMax)
    end
    
    private
    
    # Returns a string representation of the the variable's domain.
    def domain
      if assigned?
        lower_bound.to_a.inspect
      else
        "glb-range: #{lower_bound.to_a.inspect}, lub-range: #{upper_bound.to_a.inspect}"
      end
    end
  end
  
  # Describes an immutable view of an enumerable.
  class EnumerableView #:nodoc:
    # Gets the number of elements in the view.
    attr :size
    # Gets the minimum element of the view.
    attr :min
    # Gets the maximum element of the view.
    attr :max
    include Enumerable
    
    # Constructs a view with the specified minimum, maximum and size. The block 
    # should construct an enumerable containing the elements of the set.
    def initialize(min, max, size, &enum_constructor)
      @min = min
      @max = max
      @size = size
      @constructor = enum_constructor
      @enum = nil
    end

    # Iterates over every element in the view.
    def each(&block)
      enum.each(&block)
    end
    
    private
    
    # Gets the enumeration being viewed.
    def enum
      if @enum.nil?
        @enum = @constructor.call
      else
        return @enum
      end
    end
  end
end
