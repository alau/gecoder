require File.dirname(__FILE__) + '/spec_helper'

class SampleProblem < Gecode::Model
  attr :var
  attr :array
  attr :hash
  attr :nested_enum
  
  def initialize(domain)
    super()
    vars = self.int_var_array(1,domain)
    @var = vars.first
    @var.must > 1
    @array = [@var]
    @hash = {:a => var}
    @nested_enum = [1,2,[@var],[7, {:b => var}]]
    
    branch_on vars, :variable => :smallest_size, :value => :min
  end
end

describe Gecode::Model, ' (search)' do
  before do
    @domain = 0..3
    @solved_domain = [2]
    @model = SampleProblem.new(@domain)
  end

  it 'should produce a solution even if no constraints are specified' do
    @model.solve!.should_not be_nil
  end
  
  it 'should give nil if the problem can\'t be solved' do
    @model.var.must < 1
    @model.solve!.should be_nil
  end
  
  it 'should allow variables to be accessed from the solution' do
    @model.solve!.var.should have_domain(@solved_domain)
  end

  it 'should update variables in arrays' do
    @model.solve!.array.first.should have_domain(@solved_domain)
  end
  
  it 'should update variables in hashes' do
    @model.solve!.hash.values.first.should have_domain(@solved_domain)
  end
  
  it 'should update variables in nested enums' do
    enum = @model.solve!.nested_enum
    enum[2].first.should have_domain(@solved_domain)
    enum[3][1][:b].should have_domain(@solved_domain)
    
    enum = @model.nested_enum
    enum[2].first.should have_domain(@solved_domain)
    enum[3][1][:b].should have_domain(@solved_domain)
  end
end