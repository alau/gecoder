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
  
  it 'should raise error if the right hand side does not contain tuples of correct type' do
    lambda do 
      size = @variables.size
      @variables.must_be.in ['h'*size, 'i'*size] 
    end.should raise_error(TypeError)
  end
  
  it_should_behave_like 'non-reifiable constraint'
end

describe Gecode::Constraints::IntEnum::Extensional, ' (tuple constraint)' do
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
  
  it_should_behave_like 'tuple constraint'
end

describe Gecode::Constraints::BoolEnum::Extensional, ' (tuple constraint)' do
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
  
  it_should_behave_like 'tuple constraint'
end

describe Gecode::Constraints::IntEnum::Extensional, ' (regexp constraint)' do
  before do
    @model = Gecode::Model.new
    @variables = @digits = @model.int_var_array(3, 0..9)
    @model.branch_on @digits

    @expected_array = an_instance_of Gecode::Raw::IntVarArray
    @invoke_options = lambda do |hash| 
      @variables.must.match([1, @model.any(3, 4), @model.at_most_once(5)], hash)
      @model.solve!
    end
    @expect_options = option_expectation do |strength, kind, reif_var|
      Gecode::Raw.should_receive(:extensional).once.with(
        an_instance_of(Gecode::Raw::Space), 
        @expected_array, 
        an_instance_of(Gecode::Raw::REG), strength, kind)
    end
  end

  it 'should handle integers grouped in a single array' do
    @digits.must.match [3,5,3]
    @model.solve!.should_not be_nil
    @digits.values.should == [3,5,3]
  end

  it 'should allow nested groups of integers' do
    @digits.must.match [3,[5,[3]]]
    @model.solve!.should_not be_nil
    @digits.values.should == [3,5,3]
  end
  
  it 'should handle the repeat operation' do
    @digits.must.match [3, @model.repeat([5], 1, 2)]
    @model.solve!.should_not be_nil
    @digits.values.should == [3,5,5]
  end

  it 'should handle repeat operations that do not encase constant integers in arrays' do
    @digits.must.match [3, @model.repeat(5, 1, 2)]
    @model.solve!.should_not be_nil
    @digits.values.should == [3,5,5]
  end

  it 'should handle nested repeat operations' do
    @digits.must.match [[@model.repeat(@model.repeat([5], 1, 3), 1, 2)]]
    @model.solve!.should_not be_nil
    @digits.values.should == [5,5,5]
  end

  it 'should handle nested repeat operations (2)' do
    @digits.must.match [[@model.repeat([@model.repeat(5, 1, 3)], 1, 2)]]
    @model.solve!.should_not be_nil
    @digits.values.should == [5,5,5]
  end

  it 'should interpret the repeat operation with the last argument omitted as only giving a lower bound' do
    @digits.must.match [3, @model.repeat([5], 1)]
    @model.solve!.should_not be_nil
    @digits.values.should == [3,5,5]
  end

  it 'should interpret the repeat operation with all but the first argument omitted as not giving any bound' do
    @digits.must.match [@model.repeat(5), 3, 3, 3]
    @model.solve!.should_not be_nil
    @digits.values.should == [3,3,3]
  end

  it 'should interpret the repeat operation with all but the first argument omitted as not giving any bound (2)' do
    @digits.must.match [@model.repeat(5)]
    @model.solve!.should_not be_nil
    @digits.values.should == [5,5,5]
  end

  it 'should translate at_most_once(reg) to repeat(reg, 0, 1)' do
    @model.should_receive(:repeat).once.with([1], 0, 1)
    @model.at_most_once [1]
  end

  it 'should translate at_least_once(reg) to repeat(reg, 1)' do
    @model.should_receive(:repeat).once.with([1], 1)
    @model.at_least_once [1]
  end

  it 'should handle the any operation' do
    @digits.must.match [1, @model.any(1, 2, 3), 3]
    @model.solve!.should_not be_nil
    values = @digits.values
    values.size.should == 3 
    values.should == values.sort
  end

  it 'should handle the any operator with nested expressions' do
    @digits.must.match [1, @model.any(@model.at_least_once(2), [3, 5])]
    @digits[2].must < 4
    @model.solve!.should_not be_nil
    @digits.values.should == [1,2,2]
  end

  it 'should raise error if the right hand side is not an enumeration' do
    lambda{ @digits.must.match 'foo' }.should raise_error(TypeError)
  end
  
  it 'should raise error if the right hand side does not a regexp of the right type' do
    lambda{ @digits.must.match [17, 'foo'] }.should raise_error(TypeError)
  end

  it 'should raise error if the right hand side contains a nested element of an incorrect type' do
    lambda{ @digits.must.match [17, [4, 'foo']] }.should raise_error(TypeError)
  end

  it 'should raise error if the repeat operation are given arguments of incorrect type' do
    lambda do 
      @digits.must.match @model.repeat('foo', 0, 1)
    end.should raise_error(TypeError)
  end

  it 'should raise error if the repeat operation are given arguments of incorrect type (2)' do
    lambda do 
      @digits.must.match @model.repeat(4, [0], 1)
    end.should raise_error(TypeError)
  end

  it 'should raise error if the repeat operation are given arguments of incorrect type (3)' do
    lambda do 
      @digits.must.match @model.repeat(4, 0, [1])
    end.should raise_error(TypeError)
  end
  
  it 'should not allow negation' do
    lambda do 
      @variables.must_not.match 5
    end.should raise_error(Gecode::MissingConstraintError)
  end

  it_should_behave_like 'non-reifiable constraint'
end
