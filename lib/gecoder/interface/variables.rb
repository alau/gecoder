module Gecode
  # An variable that is bound to a model, but not to a particular space.  
  class FreeVarBase
    attr_accessor :model
  
    # Creates an int variable with the specified index.
    def initialize(model, index)
      @model = model
      @index = index
      @bound_space = @bound_var = nil
    end
    
    private
    
    # Returns the space that the int variable should bind to when needed.
    def active_space
      @model.active_space
    end
  end
  
  # Creates a class for a free variable that can be bound into the specified
  # class using the specified method in a space.
  def Gecode::FreeVar(bound_class, space_bind_method)
    clazz = Class.new(FreeVarBase)
    clazz.class_eval <<-"end_method_definitions"
      # Delegate methods we can't handle to the bound int variable if possible.
      def method_missing(name, *args)
        if #{bound_class}.instance_methods.include? name.to_s
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
          @bound = space.method(:#{space_bind_method}).call(@index)
          @bound_space = space
        end
        return @bound
      end
      
      def inspect
        if assigned?
          "#<#{bound_class} \#{domain}>"
        else
          "#<#{bound_class} \#{domain}>"
        end
      end
    end_method_definitions
    return clazz
  end
  
  # Int variables.
  FreeIntVar = FreeVar(Gecode::Raw::IntVar, :int_var)
  class FreeIntVar
    # Returns a string representation of the the range of the variable's domain.
    def domain
      if assigned?
        "range: #{val.to_s}"
      else
        "range: #{min}..#{max}"
      end
    end
  end
  
  # Bool variables.
  FreeBoolVar = FreeVar(Gecode::Raw::BoolVar, :bool_var)
  class FreeBoolVar
    # Returns a string representation of the the variable's domain.
    def domain
      if assigned?
        true?.to_s
      else
        'unassigned'
      end
    end
  end
  
  # Set variables.
  FreeSetVar = FreeVar(Gecode::Raw::SetVar, :set_var)
  class FreeSetVar
    # Returns a string representation of the the variable's domain.
    def domain
      if assigned?
        "#{glb_min}..#{lub_min}"
      else
        "glb-range: #{glb_min}..#{glb_max}, lub-range: #{lub_min}..#{lub_max}"
      end
    end
  end
end