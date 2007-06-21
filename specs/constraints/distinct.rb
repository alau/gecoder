require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

class DistinctSampleProblem < Gecode::Model
  attr :vars
  
  def initialize
    @vars = int_var_array(2, 1)
  end
end

describe Gecode::Constraints::IntEnum, ' (distinct)' do
  before do
    @model = DistinctSampleProblem.new
    @invoke_options = lambda{ |hash| @model.vars.must_be.distinct(hash) }
    @expect_options = lambda do |strength, reif_var|
      if reif_var.nil?
        Gecode::Raw.should_receive(:distinct).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVarArray), strength)
      else
        Gecode::Raw.should_receive(:distinct).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVarArray), strength,
          an_instance_of(Gecode::Raw::BoolVar))
      end
    end
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
  
  it_should_behave_like 'constraint with options'
end