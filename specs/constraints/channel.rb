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
  end

  it 'should translate into a channel constraint' do
    Gecode::Raw.should_receive(:channel).once.with(
      an_instance_of(Gecode::Raw::Space), 
        an_instance_of(Gecode::Raw::IntVarArray), 
        an_instance_of(Gecode::Raw::SetVarArray))
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