require File.dirname(__FILE__) + '/spec_helper'

class SampleProblem < Gecode::Model
  attr :var
  
  def initialize(domain)
    super()

    @var = self.int_var(domain)
  end
  
  # Adds a relation constraint with the specified relation and constant integer. 
  def add_constraint(integer, relation)
    @var.must.send(relation, integer)
  end
  
  # Adds a negated relation constraint with the specified relation and constant 
  # integer. 
  def add_negated_constraint(integer, relation)
    @var.must_not.send(relation, integer)
  end
end

describe Gecode::FreeIntVar, ' (relation constraints)' do
  before do
    @domain = 1..17
    @model = SampleProblem.new(@domain)
  end
  
  int = 4
  succ = int.succ
  pred = int - 1
  dom_beg = 1
  dom_end = 17
  relation_expectations = {
    '>'  => succ..dom_end,
    '>=' => int..dom_end,
    '<'  => dom_beg..pred,
    '<=' => dom_beg..int,
    '==' => int..int
  }.each_pair do |relation, expected_range|
    it "should handle #{relation} with constant integers" do
      @model.add_constraint(int, relation)
      var = @model.solution.var
      ((var.min)..(var.max)).should == expected_range
      var.size.should == expected_range.to_a.size
    end
  end
  
  negated_relation_expectations = {
    '>'  => relation_expectations['<='],
    '>=' => relation_expectations['<'],
    '<'  => relation_expectations['>='],
    '<=' => relation_expectations['>']
  }.each_pair do |relation, expected_range|
    it "should handle negated #{relation} with constant integers" do
      @model.add_negated_constraint(int, relation)
      var = @model.solution.var
      ((var.min)..(var.max)).should == expected_range
      var.size.should == expected_range.to_a.size
    end
  end
  
  # Inequality won't result in a range, so it's specified separatly.
  it 'should handle negated == with constant integers' do
    @model.add_negated_constraint(int, '==')
    var = @model.solution.var
    var.size.should == @domain.to_a.size - 1
    var.should_not be_in(int)
  end
end