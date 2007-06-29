require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

class SortSampleProblem < Gecode::Model
  attr :vars
  attr :sorted
  attr :indices
  
  def initialize
    @vars = int_var_array(4, 10..19)
    @sorted = int_var_array(4, 10..19)
    @indices = int_var_array(4, 0..9)
    
    # To make it more interesting
    @vars.must_be.distinct
    @vars[0].must > @vars[3]
    
    branch_on @vars
  end
end

describe Gecode::Constraints::IntEnum::Sort do
  before do
    @model = SortSampleProblem.new
    @vars = @model.vars
    @sorted = @model.sorted
    
    @invoke_options = lambda do |hash| 
      @vars.sorted.must.equal(@sorted, hash) 
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      Gecode::Raw.should_receive(:sortedness).once.with(@model.active_space, 
        an_instance_of(Gecode::Raw::IntVarArray), 
        an_instance_of(Gecode::Raw::IntVarArray), strength)
    end
  end
  
  it 'should translate into a sortedness constraints' do
    @expect_options.call(Gecode::Raw::ICL_DEF, nil)
    @invoke_options.call({})
  end
  
  it 'should constraint variables to be sorted' do
    @vars.sorted.must == @sorted
    @model.solve!
    values = @sorted.map{ |x| x.val }
    values.should == values.sort
  end
  
  it 'should not allow right hand sides that are not int var enums' do
    lambda{ @vars.sorted.must == 'hello' }.should raise_error(TypeError) 
  end
  
  it 'should not allow negation' do
    lambda{ @vars.sorted.must_not == @sorted }.should raise_error(
      Gecode::MissingConstraintError) 
  end
  
  it_should_behave_like 'constraint with strength option'
end

describe Gecode::Constraints::IntEnum::Sort, ' (with indices)' do
  before do
    @model = SortSampleProblem.new
    @vars = @model.vars
    @sorted = @model.sorted
    @indices = @model.indices
    
    @invoke_options = lambda do |hash| 
      @vars.sorted_with(@indices).must.equal(@sorted, hash) 
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      Gecode::Raw.should_receive(:sortedness).once.with(@model.active_space, 
        an_instance_of(Gecode::Raw::IntVarArray), 
        an_instance_of(Gecode::Raw::IntVarArray),
        an_instance_of(Gecode::Raw::IntVarArray), strength)
    end
  end
  
  it 'should translate into a sortedness constraints' do
    @expect_options.call(Gecode::Raw::ICL_DEF, nil)
    @invoke_options.call({})
  end
  
  it 'should constraint variables to be sorted with the specified indices' do
    @vars.sorted_with(@indices).must == @sorted
    @model.solve!
    sorted_values = @sorted.map{ |x| x.val }
    sorted_values.should == sorted_values.sort
    expected_indices = @vars.map{ |v| sorted_values.index(v.val) }
    @indices.map{ |i| i.val }.should == expected_indices
  end
  
  it 'should not allow right hand sides that are not int var enums' do
    lambda{ @vars.sorted_with(@indices).must == 'hello' }.should raise_error(
      TypeError) 
  end
  
  it 'should not allow indices that are not int var enums' do
    lambda{ @vars.sorted_with('hello').must == @sorted }.should raise_error(
      TypeError) 
  end
  
  it 'should not allow negation' do
    lambda do
      @vars.sorted_with(@indices).must_not == @sorted
    end.should raise_error(Gecode::MissingConstraintError) 
  end
  
  it_should_behave_like 'constraint with strength option'
end