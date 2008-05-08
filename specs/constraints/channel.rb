require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

class ChannelSampleProblem < Gecode::Model
  attr :elements
  attr :positions
  attr :sets
  
  def initialize
    @elements = int_var_array(4, 0..3)
    @elements.must_be.distinct
    @positions = int_var_array(4, 0..3)
    @positions.must_be.distinct
    @sets = set_var_array(4, [], 0..3)
    branch_on @positions
  end
end

class BoolChannelSampleProblem < Gecode::Model
  attr :bool_enum
  attr :bool
  attr :int
  
  def initialize
    @bool_enum = bool_var_array(4)
    @int = int_var(0..3)
    @bool = bool_var
    
    branch_on wrap_enum([@int])
  end
end

describe Gecode::Constraints::IntEnum::Channel, ' (two int enums)' do
  before do
    @model = ChannelSampleProblem.new
    @positions = @model.positions
    @elements = @model.elements
    @invoke_options = lambda do |hash| 
      @positions.must.channel @elements, hash
      @model.solve!
    end
    @expect_options = option_expectation do |strength, kind, reif_var|
      Gecode::Raw.should_receive(:channel).once.with(
        an_instance_of(Gecode::Raw::Space), 
        an_instance_of(Gecode::Raw::IntVarArray), 
        an_instance_of(Gecode::Raw::IntVarArray), strength, kind)
    end
  end

  it 'should translate into a channel constraint' do
    Gecode::Raw.should_receive(:channel).once.with(
      an_instance_of(Gecode::Raw::Space), 
      anything, anything, Gecode::Raw::ICL_DEF, Gecode::Raw::PK_DEF)
    @invoke_options.call({})
  end

  it 'should constrain variables to be channelled' do
    @elements.must.channel @positions
    @model.solve!
    elements = @model.elements.values
    positions = @model.elements.values
    elements.each_with_index do |element, i|
      element.should equal(positions.index(i))
    end
  end

  it 'should not allow negation' do
    lambda{ @elements.must_not.channel @positions }.should raise_error(
      Gecode::MissingConstraintError) 
  end
  
  it 'should raise error for unsupported right hand sides' do
    lambda{ @elements.must.channel 'hello' }.should raise_error(TypeError) 
  end
  
  it_should_behave_like 'reifiable constraint'
end

describe Gecode::Constraints::IntEnum::Channel, ' (one int enum and one set enum)' do
  before do
    @model = ChannelSampleProblem.new
    @positions = @model.positions
    @sets = @model.sets
    
    @invoke_options = lambda do |hash| 
      @positions.must.channel @sets, hash
      @model.solve!
    end
    @expect_options = option_expectation do |strength, kind, reif_var|
      Gecode::Raw.should_receive(:channel).once.with(
        an_instance_of(Gecode::Raw::Space), 
        an_instance_of(Gecode::Raw::IntVarArray), 
        an_instance_of(Gecode::Raw::SetVarArray))
    end
  end

  it 'should translate into a channel constraint' do
    @expect_options.call({})
    @positions.must.channel @sets
    @model.solve!
  end
  
  it 'should constrain variables to be channelled' do
    @positions.must.channel @sets
    @model.solve!
    sets = @model.sets
    positions = @model.positions.values
    positions.each_with_index do |position, i|
      sets[position].value.should include(i)
    end
  end
  
  it_should_behave_like 'non-reifiable set constraint'
end

describe Gecode::Constraints::SetEnum, ' (channel with set as left hand side)' do
  before do
    @model = ChannelSampleProblem.new
    @positions = @model.positions
    @sets = @model.sets
    
    @invoke_options = lambda do |hash| 
      @sets.must.channel @positions, hash
      @model.solve!
    end
    @expect_options = option_expectation do |strength, kind, reif_var|
      Gecode::Raw.should_receive(:channel).once.with(
        an_instance_of(Gecode::Raw::Space), 
        an_instance_of(Gecode::Raw::IntVarArray), 
        an_instance_of(Gecode::Raw::SetVarArray))
    end
  end

  it 'should translate into a channel constraint' do
    @expect_options.call({})
    @sets.must.channel @positions
    @model.solve!
  end

  it 'should not allow negation' do
    lambda{ @sets.must_not.channel @positions }.should raise_error(
      Gecode::MissingConstraintError) 
  end
  
  it 'should raise error for unsupported right hand sides' do
    lambda{ @sets.must.channel 'hello' }.should raise_error(TypeError) 
  end
  
  it_should_behave_like 'non-reifiable set constraint'
end

describe Gecode::Constraints::Int::Channel, ' (one int and one bool variable)' do
  before do
    @model = BoolChannelSampleProblem.new
    @bool = @model.bool_var
    @int = @model.int_var
    
    @invoke_options = lambda do |hash| 
      @int.must.equal(@bool, hash)
      @model.solve!
    end
    @expect_options = option_expectation do |strength, kind, reif_var|
      Gecode::Raw.should_receive(:channel).once.with(
        an_instance_of(Gecode::Raw::Space), 
        an_instance_of(Gecode::Raw::IntVar), 
        an_instance_of(Gecode::Raw::BoolVar), 
        strength, kind)
    end
  end
  
  ([:==] + Gecode::Constraints::Util::COMPARISON_ALIASES[:==]).each do |ali|
    it "should translate #{ali} into a channel constraint" do
      @expect_options.call({})
      @int.must.method(ali).call(@bool)
      @model.solve!
    end
  end
  
  it 'should not shadow linear boolean constraints' do
    lambda do
      (@bool + @bool).must == @bool
      @model.solve!
    end.should_not raise_error 
  end
  
  it 'should not allow negation' do
    lambda do
      @int.must_not == @bool
    end.should raise_error(Gecode::MissingConstraintError) 
  end
  
  it 'should raise error for unsupported right hand sides' do
    lambda{ @int.must == 'hello' }.should raise_error(TypeError) 
  end
  
  it_should_behave_like 'non-reifiable constraint'
end

describe Gecode::Constraints::Int::Channel, ' (one bool and one int variable)' do
  before do
    @model = BoolChannelSampleProblem.new
    @bool = @model.bool_var
    @int = @model.int_var
    
    @invoke_options = lambda do |hash| 
      @bool.must.equal(@int, hash)
      @model.solve!
    end
    @expect_options = option_expectation do |strength, kind, reif_var|
      Gecode::Raw.should_receive(:channel).once.with(
        an_instance_of(Gecode::Raw::Space), 
        an_instance_of(Gecode::Raw::IntVar), 
        an_instance_of(Gecode::Raw::BoolVar), 
        strength, kind)
    end
  end
  
  ([:==] + Gecode::Constraints::Util::COMPARISON_ALIASES[:==]).each do |ali|
    it "should translate #{ali} into a channel constraint" do
      @expect_options.call({})
      @bool.must.method(ali).call(@int)
      @model.solve!
    end
  end
  
  it 'should not shadow linear boolean constraints' do
    lambda do
      @bool.must == @bool + @bool
      @model.solve!
    end.should_not raise_error 
  end
  
  it 'should not allow negation' do
    lambda do
      @bool.must_not == @int
    end.should raise_error(Gecode::MissingConstraintError) 
  end
  
  it_should_behave_like 'non-reifiable constraint'
end

describe Gecode::Constraints::BoolEnum::Channel, ' (bool enum as lhs with int variable)' do
  before do
    @model = BoolChannelSampleProblem.new
    @bools = @model.bool_enum
    @int = @model.int
    
    @invoke_options = lambda do |hash| 
      @bools.must.channel(@int, hash)
      @model.solve!
    end
    @expect_options = option_expectation do |strength, kind, reif_var|
      Gecode::Raw.should_receive(:channel).once.with(
        an_instance_of(Gecode::Raw::Space), 
        an_instance_of(Gecode::Raw::BoolVarArray),
        an_instance_of(Gecode::Raw::IntVar), 0,
        strength, kind)
    end
  end
  
  it 'should channel the bool enum with the integer variable' do
    @int.must > 2
    @bools.must.channel @int
    @model.solve!.should_not be_nil
    int_val = @int.value
    @bools.values.each_with_index do |bool, index|
      bool.should == (index == int_val)
    end
  end
  
  it 'should take the offset into account when channeling' do
    @int.must > 2
    offset = 1
    @bools.must.channel(@int, :offset => offset)
    @model.solve!.should_not be_nil
    int_val = @int.value
    @bools.values.each_with_index do |bool, index|
      bool.should == (index + offset == int_val)
    end
  end

  it 'should raise error if an integer variable is not given as right hand side' do
    lambda do
      @bools.must.channel 'hello'
    end.should raise_error(TypeError) 
  end
  
  it 'should not allow negation' do
    lambda do
      @bools.must_not.channel @int
    end.should raise_error(Gecode::MissingConstraintError) 
  end
  
  it_should_behave_like 'non-reifiable constraint'
end
