require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

describe Gecode::Constraints::IntEnum::Extensional do
  before do
    @model = Gecode::Model.new
    @tuples = [[1,7], [5,1]]
    @digits = @model.int_var_array(2, 0..9)
    @model.branch_on @digits
    
    @invoke_options = lambda do |hash| 
      @digits.must_be.in(@tuples, hash) 
      @model.solve!
    end
    @expect_options = option_expectation do |strength, kind, reif_var|
      Gecode::Raw.should_receive(:extensional).once.with(
        an_instance_of(Gecode::Raw::Space), 
        an_instance_of(Gecode::Raw::IntVarArray), 
        an_instance_of(Gecode::Raw::TupleSet), strength, kind)
    end
  end
  
  it 'should constrain the domain of all variables' do
    @digits.must_be.in @tuples
    
    found_solutions = []
    @model.each_solution do |m|
      found_solutions << @digits.values
    end
    
    found_solutions.size.should == 2
    (found_solutions - @tuples).should be_empty
  end
  
  it 'should not allow negation' do
    lambda do 
      @digits.must_not_be.in @tuples
    end.should raise_error(Gecode::MissingConstraintError) 
  end
  
  it 'should raise error if the right hand side is not an enumeration' do
    lambda{ @digits.must_be.in 4711 }.should raise_error(TypeError)
  end
  
  it 'should raise error if the right hand side does not contain tuples' do
    lambda{ @digits.must_be.in [17, 4711] }.should raise_error(TypeError)
  end
  
  it 'should raise error if the right hand side does not contain integer tuples' do
    lambda{ @digits.must_be.in ['hello'] }.should raise_error(TypeError)
  end
  
  it_should_behave_like 'non-reifiable constraint'
end

describe Gecode::Constraints::BoolEnum::Extensional do
  before do
    @model = Gecode::Model.new
    @tuples = [[true, false, true], [false, false, true]]
    @bools = @model.bool_var_array(3)
    @model.branch_on @bools
    
    @invoke_options = lambda do |hash| 
      @bools.must_be.in(@tuples, hash) 
      @model.solve!
    end
    @expect_options = option_expectation do |strength, kind, reif_var|
      Gecode::Raw.should_receive(:extensional).once.with(
        an_instance_of(Gecode::Raw::Space), 
        an_instance_of(Gecode::Raw::BoolVarArray), 
        an_instance_of(Gecode::Raw::TupleSet), strength, kind)
    end
  end
  
  it 'should constrain the domain of all variables' do
    @bools.must_be.in @tuples
    
    found_solutions = []
    @model.each_solution do |m|
      found_solutions << @bools.values
    end
    
    found_solutions.size.should == 2
    (found_solutions - @tuples).should be_empty
  end
  
  it 'should not allow negation' do
    lambda do 
      @bools.must_not_be.in @tuples
    end.should raise_error(Gecode::MissingConstraintError) 
  end
  
  it 'should raise error if the right hand side is not an enumeration' do
    lambda{ @bools.must_be.in true }.should raise_error(TypeError)
  end
  
  it 'should raise error if the right hand side does not contain tuples' do
    lambda{ @bools.must_be.in [true, false] }.should raise_error(TypeError)
  end
  
  it 'should raise error if the right hand side does not contain boolean tuples' do
    lambda{ @bools.must_be.in ['hello'] }.should raise_error(TypeError)
  end
  
  it_should_behave_like 'non-reifiable constraint'
end
