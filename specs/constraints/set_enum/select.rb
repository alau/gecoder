require File.dirname(__FILE__) + '/../property_helper'

class SelectionSampleProblem < Gecode::Model
  attr :sets
  attr :set
  attr :target
  attr :index
  
  def initialize
    @sets = set_var_array(3, [], 0..20)
    @set = set_var([], 0...3)
    @target = set_var([], 0..20)
    @index = int_var(0...3)
    branch_on wrap_enum([@index])
    branch_on @sets
  end
end

# Requires everything that composite behaviour spec requires in addition to
# @stub and @expect_constrain_equal .
describe 'selection constraint', :shared => true do
  it 'should not disturb normal array access' do
    @sets[0].should be_kind_of(Gecode::SetVar)
  end
end

describe Gecode::SetEnum::Select, ' (int operand)' do
  include GecodeR::Specs::SetHelper

  before do
    @model = SelectionSampleProblem.new
    @sets = @model.sets
    @target = @set = @model.target
    @index = @model.index
    @model.branch_on @model.wrap_enum([@set])
    @stub = @sets[@index]
    
    @property_types = [:set_enum, :int]
    @select_property = lambda do |set_enum, int|
      set_enum[int]
    end
    @selected_property = @sets[@index]
    @constraint_class = Gecode::BlockConstraint
  end
  
  it 'should constrain the specified element of an enum of sets' do
    @sets[@index].must_be.superset_of([5,7,9])
    @model.solve!
    @sets[@index.value].value.should include(5,7,9)
  end

  it 'should translate into a select constraint' do
    Gecode::Raw.should_receive(:selectSet)
    @sets[@index].must_be.superset_of([5,7,9])
    @model.solve!
  end
  
  it_should_behave_like 'selection constraint'
  it_should_behave_like(
    'property that produces set operand by short circuiting equality')
end

describe Gecode::SetEnum::Select, ' (set operand)' do
  before do
    @model = SelectionSampleProblem.new
    @sets = @model.sets
    @set = @model.set
  end
  
  it 'should produce a selected set operand' do
    @sets[@set].should be_respond_to(:to_selected_set)
  end
end
