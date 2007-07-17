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
    
    branch_on @vars
  end
end

describe Gecode::Constraints::IntEnum::Sort, ' (without :as and :order)' do
  before do
    @model = SortSampleProblem.new
    @vars = @model.vars
    @sorted = @model.sorted
    
    @invoke_options = lambda do |hash| 
      @vars.must_be.sorted(hash)
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      if reif_var.nil?
        Gecode::Raw.should_receive(:rel).exactly(@vars.size - 1).times.with(
          an_instance_of(Gecode::Raw::Space), 
          an_instance_of(Gecode::Raw::IntVar), Gecode::Raw::IRT_LQ,
          an_instance_of(Gecode::Raw::IntVar), strength)
      else
        Gecode::Raw.should_receive(:rel).exactly(@vars.size - 1).times.with(
          an_instance_of(Gecode::Raw::Space), 
          an_instance_of(Gecode::Raw::IntVar), Gecode::Raw::IRT_LQ,
          an_instance_of(Gecode::Raw::IntVar), 
          an_instance_of(Gecode::Raw::BoolVar), strength)
      end
    end
  end
  
  it 'should translate into n relation constraints' do
    @expect_options.call(Gecode::Raw::ICL_DEF, nil)
    @invoke_options.call({})
  end

  it 'should constraint variables to be sorted' do
    @vars.must_be.sorted
    values = @model.solve!.vars.map{ |x| x.val }
    values.should == values.sort
  end
  
  it 'should allow negation' do
    @vars.must_not_be.sorted
    @model.solve!
    values = @vars.map{ |x| x.val }
    values.should_not == values.sort
  end
  
  it_should_behave_like 'constraint with options'
end

describe Gecode::Constraints::IntEnum::Sort, ' (with :as)' do
  before do
    @model = SortSampleProblem.new
    @vars = @model.vars
    @sorted = @model.sorted
    
    # Make it a bit more interesting.
    @vars[0].must > @vars[3] + 1
    
    @invoke_options = lambda do |hash| 
      @vars.must_be.sorted hash.update(:as => @sorted) 
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      Gecode::Raw.should_receive(:sortedness).once.with(
        an_instance_of(Gecode::Raw::Space), 
        an_instance_of(Gecode::Raw::IntVarArray), 
        an_instance_of(Gecode::Raw::IntVarArray), strength)
    end
  end
  
  it 'should translate into a sortedness constraints' do
    @expect_options.call(Gecode::Raw::ICL_DEF, nil)
    @invoke_options.call({})
  end
  
  it 'should constraint variables to be sorted' do
    @vars.must_be.sorted(:as => @sorted)
    @model.solve!
    values = @sorted.map{ |x| x.val }
    values.should == values.sort
  end
  
  it 'should not allow targets that are not int var enums' do
    lambda{ @vars.must_be.sorted(:as => 'hello') }.should raise_error(TypeError) 
  end
  
  it 'should not allow negation' do
    lambda{ @vars.must_not_be.sorted(:as => @sorted) }.should raise_error(
      Gecode::MissingConstraintError) 
  end
  
  it_should_behave_like 'constraint with strength option'
end

describe Gecode::Constraints::IntEnum::Sort, ' (with :order)' do
  before do
    @model = SortSampleProblem.new
    @vars = @model.vars
    @sorted = @model.sorted
    @indices = @model.indices
    
    # Make it a bit more interesting.
    @vars[0].must > @vars[3] + 1
    
    @invoke_options = lambda do |hash| 
      @vars.must_be.sorted hash.update(:order => @indices, :as => @sorted) 
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      Gecode::Raw.should_receive(:sortedness).once.with(
        an_instance_of(Gecode::Raw::Space), 
        an_instance_of(Gecode::Raw::IntVarArray), 
        an_instance_of(Gecode::Raw::IntVarArray),
        an_instance_of(Gecode::Raw::IntVarArray), strength)
    end
  end
  
  it 'should translate into a sortedness constraints' do
    @expect_options.call(Gecode::Raw::ICL_DEF, nil)
    @invoke_options.call({})
  end
  
  it 'should translate into a sortedness constraints, even without a target' do
    @expect_options.call(Gecode::Raw::ICL_DEF, nil)
    @vars.must_be.sorted(:order => @indices) 
    @model.solve!
  end
  
  it 'should constraint variables to be sorted with the specified indices' do
    @vars.must_be.sorted(:as => @sorted, :order => @indices)
    @model.solve!
    sorted_values = @sorted.map{ |x| x.val }
    sorted_values.should == sorted_values.sort
    expected_indices = @vars.map{ |v| sorted_values.index(v.val) }
    @indices.map{ |i| i.val }.should == expected_indices
  end
  
  it 'should not allow targets that are not int var enums' do
    lambda do
      @vars.must_be.sorted(:as => 'hello', :order => @indices)
    end.should raise_error(TypeError) 
  end
  
  it 'should not allow order that are not int var enums' do
    lambda do
      @vars.must_be.sorted(:as => @sorted, :order => 'hello')
    end.should raise_error(TypeError) 
  end
  
  it 'should not allow negation' do
    lambda do
      @vars.must_not_be.sorted(:as => @sorted, :order => @indices)
    end.should raise_error(Gecode::MissingConstraintError) 
  end
  
  it_should_behave_like 'constraint with strength option'
end