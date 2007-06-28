require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

class ChannelSampleProblem < Gecode::Model
  attr :elements
  attr :positions
  
  def initialize
    @elements = int_var_array(4, 0..3)
    @elements.must_be.distinct
    @positions = int_var_array(4, 0..3)
    @positions.must_be.distinct
    branch_on @elements
  end
end

describe Gecode::Constraints::IntEnum::Channel do
  before do
    @model = ChannelSampleProblem.new
    @positions = @model.positions
    @elements = @model.elements
    @invoke_options = lambda do |hash| 
      @positions.must.channel @elements, hash
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      Gecode::Raw.should_receive(:channel).once.with(@model.active_space, 
        an_instance_of(Gecode::Raw::IntVarArray), 
        an_instance_of(Gecode::Raw::IntVarArray), strength)
    end
  end

  it 'should translate into a channel constraint' do
    Gecode::Raw.should_receive(:channel).once.with(@model.active_space, 
      anything, anything, Gecode::Raw::ICL_DEF)
    @invoke_options.call({})
  end

  it 'should constrain variables to be channelled' do
    @elements.must.channel @positions
    @model.solve!
    elements = @model.elements.map{ |e| e.val }
    positions = @model.elements.map{ |p| p.val }
    elements.each_with_index do |element, i|
      element.should equal(positions.index(i))
    end
  end

  it 'should not allow negation' do
    lambda{ @elements.must_not.channel @positions }.should raise_error(
      Gecode::MissingConstraintError) 
  end
  
  it_should_behave_like 'constraint with strength option'
end
