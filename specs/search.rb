require File.dirname(__FILE__) + '/spec_helper'

class SampleProblem < Gecode::Model
  attr :var
  
  def initialize(domain)
    super()
    @var = self.int_var(domain)
  end
end

describe Gecode::Model, ' (search)' do
  before do
    @domain = 0..3
    @model = SampleProblem.new(@domain)
  end

  it 'should produce a solution even if no constraints are specified' do
    @model.solution.should_not be_nil
  end
  
  it 'should allow variables to be accessed from the solution' do
    var = @model.solution.var
    var.min.should equal(@domain.begin)
    var.max.should equal(@domain.end)
    var.should_not be_assigned
  end
  
  it 'should produce a solution with a new model' do
    @model.var.model.should equal(@model)
    @model.solution.var.model.should_not equal(@model)
  end
end