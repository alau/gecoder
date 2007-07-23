module Gecode
  # An variable that is bound to a model, but not to a particular space.  
  class FreeVarBase
    attr_accessor :model
  
    # Creates an int variable with the specified index.
    def initialize(model, index)
      @model = model
      @index = index
      @bound_space = @bound_var = nil
      model.track_variable(self)
    end
    
    # Checks whether the variable is cached, i.e. whether it needs to be 
    # rebound after changes to a space.
    def cached?
      not @bound_space.nil?
    end
    
    # Forces the variable to refresh itself.
    def refresh
      @bound_space = nil
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
        space = active_space
        unless @bound_space == space
          # We have not bound the variable to this space, so we do it now.
          @bound = space.method(:#{space_bind_method}).call(@index)
          @bound_space = space
        end
        return @bound
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
  
  # Int variables.
  FreeIntVar = FreeVar(Gecode::Raw::IntVar, :int_var)
  class FreeIntVar
    delegate :min
    delegate :max
    delegate :size
    delegate :width
    delegate :degree
    delegate :range?, :range
    delegate :assigned?, :assigned
    delegate :include?, :in
    
    # Gets the value of the assigned integer variable (a fixnum).
    def value
      raise 'No value is assigned.' unless assigned?
      send_bound(:val)
    end
    
    # Returns a string representation of the the range of the variable's domain.
    def domain
      if assigned?
        "range: #{value.to_s}"
      else
        "range: #{min}..#{max}"
      end
    end
  end
  
  # Bool variables.
  FreeBoolVar = FreeVar(Gecode::Raw::BoolVar, :bool_var)
  class FreeBoolVar
    delegate :assigned?, :assigned
    
    # Gets the values in the assigned boolean variable (true or false).
    def value
      raise 'No value is assigned.' unless assigned?
      send_bound(:val) == 1
    end
  
    # Returns a string representation of the the variable's domain.
    def domain
      if assigned?
        value.to_s
      else
        'unassigned'
      end
    end
  end

  # Set variables.
  FreeSetVar = FreeVar(Gecode::Raw::SetVar, :set_var)
  class FreeSetVar
    delegate :assigned?, :assigned
    
    # Gets all the elements located in the greatest lower bound of the set.
    def lower_bound
      min = send_bound(:glbMin)
      max = send_bound(:glbMax)
      EnumerableView.new(min, max, send_bound(:glbSize)) do
        (min..max).to_a.delete_if{ |e| not send_bound(:contains, e) }
      end
    end
    
    # Gets all the elements located in the least upper bound of the set.
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
  class EnumerableView
    attr :size
    attr :min
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

    # Used by Enumerable.
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