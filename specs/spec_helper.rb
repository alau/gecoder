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
end

Spec::Runner.configure do |config|
  config.include(CustomVarMatchers)
end
