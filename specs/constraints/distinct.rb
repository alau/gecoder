require File.dirname(__FILE__) + '/../spec_helper'

class DistinctSampleProblem < Gecode::Model
  attr :vars
  
  def initialize
    @vars = int_var_array(2, 1)
  end
end

describe 'distinct constraints' do
  before do
    @model = DistinctSampleProblem.new
  end
  
  it 'should translate into a distinct constraint' do
    Gecode::Raw.should_receive(:distinct).once.with(@model.active_space, 
      anything, Gecode::Raw::ICL_DEF)
    @model.vars.must_be.distinct
  end

  it 'should constrain variables to be distinct' do
    # This won't work well without branching or propagation strengths. So this
    # just shows that the distinct constraint will cause trivially unsolvable
    # problems to directly fail.
    @model.vars.must_be.distinct
    @model.solve!.should be_nil
  end
  
  it 'should not allow negation' do
    lambda{ @model.vars.must_not_be.distinct }.should raise_error(
      Gecode::MissingConstraintError) 
  end
  
  it 'should translate reification' do
    Gecode::Raw.should_receive(:distinct).once.with(@model.active_space, 
      anything, Gecode::Raw::ICL_DEF, an_instance_of(Gecode::Raw::BoolVar))
    @model.vars.must_be.distinct(:reify => @model.bool_var)
  end
  
  { :default  => Gecode::Raw::ICL_DEF,
    :value    => Gecode::Raw::ICL_VAL,
    :bounds   => Gecode::Raw::ICL_BND,
    :domain   => Gecode::Raw::ICL_DOM
  }.each_pair do |name, gecode_value|
    it 'should translate propagation strength #{name}' do
      Gecode::Raw.should_receive(:distinct).once.with(@model.active_space, 
        anything, gecode_value)
      @model.vars.must_be.distinct(:strength => name)
    end
  end
  
  it 'should default to using default as propagation strength' do
    Gecode::Raw.should_receive(:distinct).once.with(@model.active_space, 
      anything, Gecode::Raw::ICL_DEF)
    @model.vars.must_be.distinct()
  end
  
  it 'should raise errors for unrecognized options' do
    lambda{ @model.vars.must_be.distinct(:does_not_exist => :foo) }.should(
      raise_error(ArgumentError))
  end
  
  it 'should raise errors for unrecognized propagation strengths' do
    lambda{ @model.vars.must_be.distinct(:strength => :does_not_exist) }.should(
      raise_error(ArgumentError))
  end
  
  it 'should raise errors for reification variables of incorrect type' do
    lambda{ @model.vars.must_be.distinct(:reify => 'foo') }.should(
      raise_error(TypeError))
  end
end