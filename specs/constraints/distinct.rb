require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

class DistinctSampleProblem < Gecode::Model
  attr :vars
  attr :sets
  
  def initialize
    @vars = int_var_array(2, 1)
    @sets = set_var_array(2, [], 0..1)
  end
end

describe Gecode::Constraints::IntEnum::Distinct do
  before do
    @model = DistinctSampleProblem.new
    @invoke_options = lambda do |hash| 
      @model.vars.must_be.distinct(hash)
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      Gecode::Raw.should_receive(:distinct).once.with(@model.active_space, 
        an_instance_of(Gecode::Raw::IntVarArray), strength)
    end
  end

  it 'should translate into a distinct constraint' do
    Gecode::Raw.should_receive(:distinct).once.with(@model.active_space, 
      anything, Gecode::Raw::ICL_DEF)
    @invoke_options.call({})
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
  
  it_should_behave_like 'constraint with strength option'
end

describe Gecode::Constraints::IntEnum::Distinct, ' (with offsets)' do
  before do
    @model = DistinctSampleProblem.new
    @invoke_options = lambda do |hash| 
      @model.vars.with_offsets(1,2).must_be.distinct(hash)
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      if reif_var.nil?
        Gecode::Raw.should_receive(:distinct).once.with(@model.active_space, 
          anything, an_instance_of(Gecode::Raw::IntVarArray), strength)
      else
        Gecode::Raw.should_receive(:distinct).once.with(@model.active_space, 
          anything, an_instance_of(Gecode::Raw::IntVarArray), strength,
          an_instance_of(Gecode::Raw::BoolVar))
      end
    end
  end

  it 'should translate into a distinct constraint with offsets' do
    Gecode::Raw.should_receive(:distinct).once.with(@model.active_space, 
      anything, anything, Gecode::Raw::ICL_DEF)
    @invoke_options.call({})
  end

  it 'should consider offsets when making variables distinct' do
    @model.vars.with_offsets(-1,0).must_be.distinct
    x,y = @model.solve!.vars
    x.val.should equal(1)
    y.val.should equal(1)
  end
  
  # This tests two distinct in conjunction. It's here because of a bug found.
  it 'should play nice with normal distinct' do
    @model.vars.with_offsets(-1,0).must_be.distinct
    @model.vars.must_be.distinct
    @model.solve!.should be_nil
  end
  
  it 'should accept an array as offsets' do
    @model.vars.with_offsets([-1,0]).must_be.distinct
    x,y = @model.solve!.vars
    x.val.should equal(1)
    y.val.should equal(1)
  end
  
  it 'should not allow negation' do
    lambda{ @model.vars.with_offsets(1,2).must_not_be.distinct }.should 
      raise_error(Gecode::MissingConstraintError)
  end
  
  it_should_behave_like 'constraint with strength option'
end

describe Gecode::Constraints::SetEnum::Distinct do
  before do
    @model = DistinctSampleProblem.new
    @sets = @model.sets
    @size = 1
    
    @invoke_options = lambda do |hash| 
      @sets.must_be.distinct(hash.update(:size => @size))
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      Gecode::Raw.should_receive(:distinct).once.with(@model.active_space, 
        an_instance_of(Gecode::Raw::SetVarArray), @size)
    end
  end

  it 'should translate into a distinct constraint' do
    Gecode::Raw.should_receive(:distinct).once.with(@model.active_space, 
      an_instance_of(Gecode::Raw::SetVarArray), @size)
    @sets.must_be.distinct(:size => @size)
    @model.solve!
  end

  it 'should constrain sets to be distinct' do
    @sets.must_be.distinct(:size => @size)
    @sets[0].must_be.superset_of 0
    solution = @model.solve!
    solution.should_not be_nil
    set1, set2 = solution.sets
    set1.glb.size.should == @size
    set2.glb.size.should == @size
    set1.glb.should_not == set2.glb
  end
  
  it 'should not allow negation' do
    lambda{ @sets.must_not_be.distinct(:size => @size) }.should raise_error(
      Gecode::MissingConstraintError)
  end
  
  it 'should not allow options other than :size' do
    lambda do
      @sets.must_not_be.distinct(:size => @size, :foo => 17)
    end.should raise_error(ArgumentError)
  end
  
  it 'should not calls that do not specify :size' do
    lambda{ @sets.must_be.distinct }.should raise_error(ArgumentError)
  end
  
  it_should_behave_like 'non-reifiable set constraint'
end