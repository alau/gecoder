require File.dirname(__FILE__) + '/../lib/gecoder'

module CustomVarMatchers
  class HaveDomain
    def initialize(expected)
      @expected = expected.to_a
    end
    
    def matches?(target)
      @target = target
      return false unless @target.size == @expected.size
      @expected.each do |element|
        return false unless @target.in(element)
      end
      return true
    end
    
    def failure_message
      "expected #{@target.inspect} to have domain #{@expected.inspect}"
    end
    
    def negative_failure_message
      "expected #{@target.inspect} not to have domain #{@expected.inspect}"
    end
  end

  # Tests whether a variable has the expected domain.
  def have_domain(expected)
    HaveDomain.new(expected)
  end
  
  class HaveBounds
    def initialize(expected_glb, expected_lub)
      @expected_glb = expected_glb.to_a
      @expected_lub = expected_lub.to_a
    end
    
    def matches?(target)
      @target = target
      return false unless @target.glb_size == @expected_glb.size and
        @target.lub_size == @expected_lub.size
      @expected_glb.each do |element|
        return false unless @target.include_glb?(element)
      end
      @expected_lub.each do |element|
        return false unless @target.include_lub?(element)
      end
      return true
    end
    
    def failure_message
      "expected #{@target.inspect} to have greatest lower bound " + 
        "#{@expected_glb.inspect} and least upper bound #{@expected_lub.inspect}"
    end
    
    def negative_failure_message
      "expected #{@target.inspect} to not have greatest lower bound " + 
        "#{@expected_glb.inspect} and least upper bound #{@expected_lub.inspect}"
    end
  end

  # Tests whether a set variable has the expected bounds.
  def have_bounds(expected_glb, expected_lub)
    HaveBounds.new(expected_glb, expected_lub)
  end
  
  class IsAlias
    def initialize(expected)
      @expected = expected.to_a
    end
    
    def matches?(target)
      @target = target
      return false unless @target.size == @expected.size
      @expected.each do |element|
        return false unless @target.in(element)
      end
      return true
    end
    
    def failure_message
      "expected #{@target.inspect} to be an alias of #{@expected.inspect}"
    end
    
    def negative_failure_message
      "expected #{@target.inspect} not to be an alias of #{@expected.inspect}"
    end
  end

  # Tests whether a method with a specified name is the alias of another.
  def is_alias_of(expected)
    HaveDomain.new(expected)
  end
end

Spec::Runner.configure do |config|
  config.include(CustomVarMatchers)
end
