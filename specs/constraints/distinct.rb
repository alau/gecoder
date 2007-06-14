require File.dirname(__FILE__) + '/../spec_helper'

class DistinctSampleProblem < Gecode::Model
  attr :vars
  
  def initialize
    super()

    @vars = int_var_array(2, 1)
  end
end

describe 'distinct constraints' do
  before do
    @model = DistinctSampleProblem.new
  end
  
  it 'should constrain variables to be distinct' do
    # This won't work well without branching or propagation strengths. So this
    # just shows that the distinct constraint will cause trivially unsolvable
    # problems to directly fail.
    @model.vars.must_be.distinct
    @model.solution.should be_nil
  end
  
  it 'should not allow negation' do
    lambda{ @model.vars.must_not_be.distinct }.should raise_error(
      Gecode::MissingConstraintError) 
  end
end