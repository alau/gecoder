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