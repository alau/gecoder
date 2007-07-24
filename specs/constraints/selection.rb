require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

class SelectionSampleProblem < Gecode::Model
  attr :sets
  attr :set
  attr :target
  attr :index
  
  def initialize
    @sets = set_var_array(17, [], 0..20)
    @set = set_var([], 0...17)
    @target = set_var([], 0..20)
    @index = int_var(0..16)
    branch_on wrap_enum([@index])
    branch_on @sets
  end
end

# Requires everything that composite behaviour spec requires in addition to
# @stub and @expect_constrain_equal .
describe 'selection constraint', :shared => true do
  before do
    @expect = lambda do |index, relation, target, reif_var, negated|
      @model.allow_space_access do
        if target.respond_to? :bind
          expected_target = [an_instance_of(Gecode::Raw::SetVar)]
          relation_constraint = :rel
        else
          expected_target = expect_constant_set(target)
          relation_constraint = :dom
        end
        if reif_var.nil?
          if !negated and relation == Gecode::Raw::IRT_EQ and 
              !target.kind_of? Enumerable
            @expect_constrain_equal.call
            Gecode::Raw.should_receive(:rel).exactly(0).times
            Gecode::Raw.should_receive(:dom).exactly(0).times
          else
            @expect_constrain_equal.call
            if relation_constraint == :dom
              # We can't seem to get any more specific than this with mocks. 
              Gecode::Raw.should_receive(relation_constraint).at_most(:twice)
            else
              Gecode::Raw.should_receive(relation_constraint).once.with(
                an_instance_of(Gecode::Raw::Space), 
                an_instance_of(Gecode::Raw::SetVar), relation, *expected_target)
            end
          end
        else
          @expect_constrain_equal.call
          if relation_constraint == :dom
            Gecode::Raw.should_receive(relation_constraint).at_least(:twice)
          else
            expected_target << an_instance_of(Gecode::Raw::BoolVar)
            Gecode::Raw.should_receive(relation_constraint).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::SetVar), relation, *expected_target)
          end
        end
      end
    end
    
    # For composite spec.
    @invoke_relation = lambda do |relation, target, negated|
      if negated
        @stub.must_not.send(relation, target)
      else
        @stub.must.send(relation, target)
      end
      @model.solve!
    end
    @expect_relation = lambda do |relation, target, negated|
      @expect.call(@index, relation, target, nil, negated)
    end
    
    # For options spec.
    @invoke_options = lambda do |hash|
      @stub.must_be.subset_of(@target, hash)
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      @expect.call(17, Gecode::Raw::SRT_SUB, @target, reif_var, false)
    end
  end
  
  it 'should not disturb normal array access' do
    @sets[0].should be_kind_of(Gecode::FreeSetVar)
  end
  
  it_should_behave_like 'reifiable set constraint'
  it_should_behave_like 'composite set constraint'
end

describe Gecode::Constraints::SetEnum::Selection, ' (select)' do
  include GecodeR::Specs::SetHelper

  before do
    @model = SelectionSampleProblem.new
    @sets = @model.sets
    @target = @set = @model.target
    @index = @model.index
    @model.branch_on @model.wrap_enum([@set])
    @stub = @sets[@index]
    
    @expect_constrain_equal = lambda do
      Gecode::Raw.should_receive(:selectSet).once.with( 
        an_instance_of(Gecode::Raw::Space),
        an_instance_of(Gecode::Raw::SetVarArray), 
        an_instance_of(Gecode::Raw::IntVar),
        an_instance_of(Gecode::Raw::SetVar))
    end
  end
  
  it 'should constrain the specified element of an enum of sets' do
    @sets[@index].must_be.superset_of([5,7,9])
    @model.solve!
    @sets[@index.value].value.should include(5,7,9)
  end
  
  it_should_behave_like 'selection constraint'
end

describe Gecode::Constraints::SetEnum::Selection, ' (union)' do
  include GecodeR::Specs::SetHelper

  before do
    @model = SelectionSampleProblem.new
    @sets = @model.sets
    @set = @model.set
    @target = @model.target
    @model.branch_on @model.wrap_enum([@target, @set])
    @stub = @sets[@set].union
    
    @expect_constrain_equal = lambda do
      Gecode::Raw.should_receive(:selectUnion).once.with( 
        an_instance_of(Gecode::Raw::Space),
        an_instance_of(Gecode::Raw::SetVarArray), 
        an_instance_of(Gecode::Raw::SetVar), 
        an_instance_of(Gecode::Raw::SetVar))
    end
  end
  
  it 'should constrain the selected union of an enum of sets' do
    @sets[@set].union.must_be.subset_of([5,7,9])
    @sets[@set].union.must_be.superset_of([5])
    @model.solve!
    union = @set.value.inject([]) do |union, i|
      union += @sets[i].value.to_a
    end.uniq
    union.should include(5)
    (union - [5,7,9]).should be_empty
  end
  
  it_should_behave_like 'selection constraint'
end

describe Gecode::Constraints::SetEnum::Selection, ' (intersection)' do
  include GecodeR::Specs::SetHelper

  before do
    @model = SelectionSampleProblem.new
    @sets = @model.sets
    @set = @model.set
    @target = @model.target
    @model.branch_on @model.wrap_enum([@target, @set])
    @stub = @sets[@set].intersection
    
    @expect_constrain_equal = lambda do
      Gecode::Raw.should_receive(:selectInter).once.with( 
        an_instance_of(Gecode::Raw::Space),
        an_instance_of(Gecode::Raw::SetVarArray), 
        an_instance_of(Gecode::Raw::SetVar), 
        an_instance_of(Gecode::Raw::SetVar))
    end
  end
  
  it 'should constrain the selected intersection of an enum of sets' do
    @sets[@set].intersection.must_be.subset_of([5,7,9])
    @sets[@set].intersection.must_be.superset_of([5])
    @model.solve!
    intersection = @set.value.inject(nil) do |intersection, i|
      elements = @sets[i].value.to_a
      next elements if intersection.nil?
      intersection &= elements
    end.uniq
    intersection.should include(5)
    (intersection - [5,7,9]).should be_empty
  end
  
  it_should_behave_like 'selection constraint'
end

describe Gecode::Constraints::SetEnum::Selection, ' (intersection with universe)' do
  include GecodeR::Specs::SetHelper

  before do
    @model = SelectionSampleProblem.new
    @sets = @model.sets
    @set = @model.set
    @target = @model.target
    @model.branch_on @model.wrap_enum([@target, @set])
    @universe = [1,2]
    @stub = @sets[@set].intersection(:with => @universe)
    
    @expect_constrain_equal = lambda do
      Gecode::Raw.should_receive(:selectInterIn).once.with( 
        an_instance_of(Gecode::Raw::Space),
        an_instance_of(Gecode::Raw::SetVarArray), 
        an_instance_of(Gecode::Raw::SetVar), 
        an_instance_of(Gecode::Raw::SetVar),
        an_instance_of(Gecode::Raw::IntSet))
    end
  end
  
  it 'should constrain the selected intersection of an enum of sets in a universe' do
    @sets[@set].intersection(:with => @universe).must_be.subset_of([2])
    @model.solve!
    intersection = @set.value.inject(@universe) do |intersection, i|
      intersection &= @sets[i].value.to_a
    end.uniq
    intersection.should include(2)
    (intersection - [1,2]).should be_empty
  end
  
  it 'should allow the universe to be specified as a range' do
    @sets[@set].intersection(:with => 1..2).must_be.subset_of([2])
    @model.solve!
    intersection = @set.value.inject(@universe) do |intersection, i|
      intersection &= @sets[i].value.to_a
    end.uniq
    intersection.should include(2)
    (intersection - [1,2]).should be_empty
  end
  
  it 'should raise error if unknown options are specified' do
    lambda do
      @sets[@set].intersection(:does_not_exist => nil).must_be.subset_of([2])
    end.should raise_error(ArgumentError)
  end
  
  it 'should raise error if the universe is of the wrong type' do
    lambda do
      @sets[@set].intersection(:with => 'foo').must_be.subset_of([2])
    end.should raise_error(TypeError)
  end
  
  it_should_behave_like 'selection constraint'
end