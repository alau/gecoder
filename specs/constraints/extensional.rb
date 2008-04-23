require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

# Assumes that @variables, @expected_array and @tuples are defined.
describe 'tuple constraint', :shared => true do
  before do
    @invoke_options = lambda do |hash| 
      @variables.must_be.in(@tuples, hash) 
      @model.solve!
    end
    @expect_options = option_expectation do |strength, kind, reif_var|
      Gecode::Raw.should_receive(:extensional).once.with(
        an_instance_of(Gecode::Raw::Space), 
        @expected_array, 
        an_instance_of(Gecode::Raw::TupleSet), strength, kind)
    end
  end
  
  it 'should not allow negation' do
    lambda do 
      @variables.must_not_be.in @tuples
    end.should raise_error(Gecode::MissingConstraintError)
  end
  
  it 'should not allow empty tuples' do
    lambda do 
      @variables.must_be.in []
    end.should raise_error(ArgumentError)
  end
  
  it 'should not allow tuples of sizes other than the number of variables' do
    lambda do 
      @variables.must_be.in([@tuples.first * 2])
    end.should raise_error(ArgumentError)
  end
  
  it_should_behave_like 'non-reifiable constraint'
end

describe Gecode::Constraints::IntEnum::Extensional do
  before do
    @model = Gecode::Model.new
    @tuples = [[1,7], [5,1]]
    @variables = @digits = @model.int_var_array(2, 0..9)
    @model.branch_on @digits
    
    @expected_array = an_instance_of Gecode::Raw::IntVarArray
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
  
  it 'should raise error if the right hand side is not an enumeration' do
    lambda{ @digits.must_be.in 4711 }.should raise_error(TypeError)
  end
  
  it 'should raise error if the right hand side does not contain tuples' do
    lambda{ @digits.must_be.in [17, 4711] }.should raise_error(TypeError)
  end
  
  it 'should raise error if the right hand side does not contain integer tuples' do
    lambda{ @digits.must_be.in ['hello'] }.should raise_error(TypeError)
  end
  
  it_should_behave_like 'tuple constraint'
end

describe Gecode::Constraints::BoolEnum::Extensional do
  before do
    @model = Gecode::Model.new
    @tuples = [[true, false, true], [false, false, true]]
    @variables = @bools = @model.bool_var_array(3)
    @model.branch_on @bools
    
    @expected_array = an_instance_of Gecode::Raw::BoolVarArray
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
  
  it 'should raise error if the right hand side is not an enumeration' do
    lambda{ @bools.must_be.in true }.should raise_error(TypeError)
  end
  
  it 'should raise error if the right hand side does not contain tuples' do
    lambda{ @bools.must_be.in [true, false] }.should raise_error(TypeError)
  end
  
  it 'should raise error if the right hand side does not contain boolean tuples' do
    lambda{ @bools.must_be.in ['hello'] }.should raise_error(TypeError)
  end
  
  it_should_behave_like 'tuple constraint'
end
