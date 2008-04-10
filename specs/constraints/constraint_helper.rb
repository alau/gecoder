require File.dirname(__FILE__) + '/../spec_helper'

# Several of these shared specs requires one or more of the following instance 
# variables to be used: 
# [@expect_options]  A method that creates an expectation on the aspect to be 
#                    tested, using the provided hash of Gecode values. The hash 
#                    can have values for the keys :icl (ICL_*), :pk (PK_*), and 
#                    :bool (bound reification variable). Any values not 
#                    provided are assumed to be default values (nil in the case 
#                    of :bool).
# [@invoke_options]  A method that invokes the aspect to be tested, with the 
#                    provided hash of options (with at most the keys :strength, 
#                    :kind and :reify).
# [@model]           The model instance that contains the aspects being tested.
# [@expect_relation] A method that takes a relation, right hand side, and 
#                    whether it's negated, as arguments and sets up the 
#                    corresponding expectations. 
# [@invoke_relation] A method that takes a relation, right hand side, and 
#                    whether it's negated, as arguments and adds the 
#                    corresponding constraint and invokes it.
# [@target]          A legal right hand side that can be used as argument to 
#                    the above two methods.


# Requires @invoke_options and @expect_options.
describe 'constraint with strength option', :shared => true do
  { :default  => Gecode::Raw::ICL_DEF,
    :value    => Gecode::Raw::ICL_VAL,
    :bounds   => Gecode::Raw::ICL_BND,
    :domain   => Gecode::Raw::ICL_DOM
  }.each_pair do |name, gecode_value|
    it "should translate propagation strength #{name}" do
      @expect_options.call(:icl => gecode_value)
      @invoke_options.call(:strength => name)
    end
  end
  
  it 'should default to using default as propagation strength' do
    @expect_options.call({})
    @invoke_options.call({})
  end
  
  it 'should raise errors for unrecognized propagation strengths' do
    lambda do 
      @invoke_options.call(:strength => :does_not_exist) 
    end.should raise_error(ArgumentError)
  end
end

# Requires @invoke_options and @expect_options.
describe 'constraint with kind option', :shared => true do
  { :default  => Gecode::Raw::PK_DEF,
    :speed    => Gecode::Raw::PK_SPEED,
    :memory   => Gecode::Raw::PK_MEMORY
  }.each_pair do |name, gecode_value|
    it "should translate propagation kind #{name}" do
      @expect_options.call(:pk => gecode_value)
      @invoke_options.call(:kind => name)
    end
  end
  
  it 'should default to using default as propagation kind' do
    @expect_options.call({})
    @invoke_options.call({})
  end
  
  it 'should raise errors for unrecognized propagation kinds' do
    lambda do 
      @invoke_options.call(:kind => :does_not_exist)
    end.should raise_error(ArgumentError)
  end
end


# Requires @invoke_options and @expect_options.
describe 'constraint with reification option', :shared => true do
  it 'should translate reification' do
    var = @model.bool_var
    @expect_options.call(:bool => var)
    @invoke_options.call(:reify => var)
  end
  
  it 'should raise errors for reification variables of incorrect type' do
    lambda do 
      @invoke_options.call(:reify => 'foo')
    end.should raise_error(TypeError)
  end
end

# Requires @invoke_options and @expect_options.
describe 'reifiable constraint', :shared => true do
  it_should_behave_like 'constraint with default options'
  it_should_behave_like 'constraint with reification option'
end

# Requires @invoke_options, @expect_options and @model.
describe 'non-reifiable constraint', :shared => true do
  it 'should raise errors if reification is used' do
    lambda do 
      @invoke_options.call(:reify => @model.bool_var)
    end.should raise_error(ArgumentError)
  end
  
  it_should_behave_like 'constraint with default options'
end

# Requires @invoke_options and @expect_options.
describe 'constraint with default options', :shared => true do
  it 'should raise errors for unrecognized options' do
    lambda{ @invoke_options.call(:does_not_exist => :foo) }.should(
      raise_error(ArgumentError))
  end
  
  it_should_behave_like 'constraint with strength option'
  it_should_behave_like 'constraint with kind option'
end

# Requires @expect_relation, @invoke_relation and @target.
describe 'composite constraint', :shared => true do
  Gecode::Constraints::Util::RELATION_TYPES.each_pair do |relation, type|
    it "should translate #{relation} with constant target" do
      @expect_relation.call(type, 1, false)
      @invoke_relation.call(relation, 1, false)
    end
  end
  
  Gecode::Constraints::Util::RELATION_TYPES.each_pair do |relation, type|
    it "should translate #{relation} with variable target" do
      @expect_relation.call(type, @target, false)
      @invoke_relation.call(relation, @target, false)
    end
  end
  
  Gecode::Constraints::Util::NEGATED_RELATION_TYPES.each_pair do |relation, type|
    it "should translate negated #{relation} with constant target" do
      @expect_relation.call(type, 1, true)
      @invoke_relation.call(relation, 1, true)
    end
  end
  
  Gecode::Constraints::Util::NEGATED_RELATION_TYPES.each_pair do |relation, type|
    it "should translate negated #{relation} with variable target" do
      @expect_relation.call(type, @target, true)
      @invoke_relation.call(relation, @target, true)
    end
  end

  it 'should raise error if the target is of the wrong type' do
    lambda do 
      @invoke_relation.call(:==, 'hello', false)
    end.should raise_error(TypeError) 
  end
end

# Requires @expect_relation, @invoke_relation and @target.
describe 'composite set constraint', :shared => true do
  Gecode::Constraints::Util::SET_RELATION_TYPES.each_pair do |relation, type|
    it "should translate #{relation} with constant target" do
      @expect_relation.call(type, [1], false)
      @invoke_relation.call(relation, [1], false)
    end
  end
  
  Gecode::Constraints::Util::SET_RELATION_TYPES.each_pair do |relation, type|
    it "should translate #{relation} with variable target" do
      @expect_relation.call(type, @target, false)
      @invoke_relation.call(relation, @target, false)
    end
  end
  
  Gecode::Constraints::Util::NEGATED_SET_RELATION_TYPES.each_pair do |relation, type|
    it "should translate negated #{relation} with constant target" do
      @expect_relation.call(type, [1], true)
      @invoke_relation.call(relation, [1], true)
    end
  end
  
  Gecode::Constraints::Util::NEGATED_SET_RELATION_TYPES.each_pair do |relation, type|
    it "should translate negated #{relation} with variable target" do
      @expect_relation.call(type, @target, true)
      @invoke_relation.call(relation, @target, true)
    end
  end

  it 'should raise error if the target is of the wrong type' do
    lambda do 
      @invoke_relation.call(:==, 'hello', false)
    end.should raise_error(TypeError) 
  end
end

describe 'set constraint', :shared => true do
  it 'should not accept strength option' do
    lambda do 
      @invoke_options.call(:strength => :default)
    end.should raise_error(ArgumentError)
  end
  
  it 'should not accept kind option' do
    lambda do 
      @invoke_options.call(:kind => :default)
    end.should raise_error(ArgumentError)
  end
  
  it 'should raise errors for unrecognized options' do
    lambda do 
      @invoke_options.call(:does_not_exist => :foo) 
    end.should raise_error(ArgumentError)
  end
end

# Requires @invoke_options and @model.
describe 'non-reifiable set constraint', :shared => true do
  it 'should not accept reification option' do
    bool = @model.bool_var
    lambda do 
      @invoke_options.call(:reify => bool)
    end.should raise_error(ArgumentError)
  end
  
  it_should_behave_like 'set constraint'
end

# Requires @invoke_options, @expect_options and @model.
describe 'reifiable set constraint', :shared => true do
  it_should_behave_like 'set constraint'
  it_should_behave_like 'constraint with reification option'
end

# Help methods for the GecodeR specs. 
module GecodeR::Specs
  module SetHelper
    module_function
  
    # Returns the arguments that should be used in a partial mock to expect the
    # specified constant set (possibly an array of arguments).
    def expect_constant_set(constant_set)
      if constant_set.kind_of? Range
        return constant_set.first, constant_set.last
      elsif constant_set.kind_of? Fixnum
        constant_set
      else
        an_instance_of(Gecode::Raw::IntSet)
      end
    end
  end
end

# Helper for creating @expect_option. Creates a method which takes a hash that
# may have values for the keys :icl (ICL_*), :pk (PK_*), and :bool (reification 
# variable). Expectations corresponding to the hash values are given to the 
# specified block in the order of icl, pk and bool. Default values are provided 
# if the hash doesn't specify anything else.
def option_expectation(&block)
  lambda do |hash|
    bool = hash[:bool]
    # We loosen the expectation some to avoid practical problems with expecting
    # specific variables not under our control.
    bool = an_instance_of(Gecode::Raw::BoolVar) unless bool.nil?
    yield(hash[:icl] || Gecode::Raw::ICL_DEF,
      hash[:pk]  || Gecode::Raw::PK_DEF,
      bool)
  end
end
