require File.dirname(__FILE__) + '/../spec_helper'

# This requires that the constraint spec has instance variables @invoke_options
# and @expect_options .
describe 'constraint with strength option', :shared => true do
  { :default  => Gecode::Raw::ICL_DEF,
    :value    => Gecode::Raw::ICL_VAL,
    :bounds   => Gecode::Raw::ICL_BND,
    :domain   => Gecode::Raw::ICL_DOM
  }.each_pair do |name, gecode_value|
    it "should translate propagation strength #{name}" do
      @expect_options.call(gecode_value, nil)
      @invoke_options.call(:strength => name)
    end
  end
  
  it 'should default to using default as propagation strength' do
    @expect_options.call(Gecode::Raw::ICL_DEF, nil)
    @invoke_options.call({})
  end
  
  it 'should raise errors for unrecognized options' do
    lambda{ @invoke_options.call(:does_not_exist => :foo) }.should(
      raise_error(ArgumentError))
  end
  
  it 'should raise errors for unrecognized propagation strengths' do
    lambda{ @invoke_options.call(:strength => :does_not_exist) }.should(
      raise_error(ArgumentError))
  end
  
  it 'should raise errors for reification variables of incorrect type' do
    lambda{ @invoke_options.call(:reify => 'foo') }.should(
      raise_error(TypeError))
  end
end

# This requires that the constraint spec has instance variables @invoke_options
# and @expect_options .
describe 'constraint with options', :shared => true do
  it 'should translate reification' do
    var = @model.bool_var
    @expect_options.call(Gecode::Raw::ICL_DEF, var)
    @invoke_options.call(:reify => var)
  end
  
  it_should_behave_like 'constraint with strength option'
end

# This requires that the constraint spec has the instance variable 
# @expect_relation which takes a relation and right hand side as arguments and 
# sets up the corresponding expectations. It also requires @invoke_relation and
# @invoke_negated_relation with the same arguments. The spec is also required to 
# provide an int var @target.
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