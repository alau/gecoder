require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

class SelectionSampleProblem < Gecode::Model
  attr :sets
  attr :set
  attr :index
  
  def initialize
    @sets = set_var_array(17, [], 0..20)
    @set = set_var([], 0..20)
    @index = int_var(0..16)
    branch_on wrap_enum([@index])
    branch_on @sets
  end
end

describe Gecode::Constraints::SetEnum::Selection, ' (select)' do
  include GecodeR::Specs::SetHelper

  before do
    @model = SelectionSampleProblem.new
    @sets = @model.sets
    @target = @set = @model.set
    @index = @model.index
    @model.branch_on @model.wrap_enum([@set])
    @stub = @sets[@index]
    
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
            Gecode::Raw.should_receive(:selectSet).once.with( 
              an_instance_of(Gecode::Raw::Space),
              an_instance_of(Gecode::Raw::SetVarArray), 
              an_instance_of(Gecode::Raw::IntVar), *expected_target)
            Gecode::Raw.should_receive(:rel).exactly(0).times
            Gecode::Raw.should_receive(:dom).exactly(0).times
          else
            Gecode::Raw.should_receive(:selectSet).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::SetVarArray), 
              an_instance_of(Gecode::Raw::IntVar),
              an_instance_of(Gecode::Raw::SetVar))
            if relation_constraint == :dom
              # We can't seem to get any more specific than this with mocks. 
              Gecode::Raw.should_receive(relation_constraint).twice
            else
              Gecode::Raw.should_receive(relation_constraint).once.with(
                an_instance_of(Gecode::Raw::Space), 
                an_instance_of(Gecode::Raw::SetVar), relation, *expected_target)
            end
          end
        else
          Gecode::Raw.should_receive(:selectSet).once.with( 
            an_instance_of(Gecode::Raw::Space),
            an_instance_of(Gecode::Raw::SetVarArray), 
            an_instance_of(Gecode::Raw::IntVar), 
            an_instance_of(Gecode::Raw::SetVar))
          if relation_constraint == :dom
            Gecode::Raw.should_receive(relation_constraint).twice
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
      @stub.must_be.subset_of(@set, hash)
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      @expect.call(17, Gecode::Raw::SRT_SUB, @set, reif_var, false)
    end
  end
  
  it 'should constrain the specified element of an enum of sets' do
    @sets[@index].must_be.superset_of([5,7,9])
    @model.solve!
    @sets[@index.value].value.should include(5,7,9)
  end
  
  it 'should not disturb normal array access' do
    @sets[0].should be_kind_of(Gecode::FreeSetVar)
  end
  
  it_should_behave_like 'reifiable set constraint'
  it_should_behave_like 'composite set constraint'
end

