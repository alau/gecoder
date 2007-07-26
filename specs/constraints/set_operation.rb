require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

describe Gecode::Constraints::Set::Operation do
  before do
    @model = Gecode::Model.new
    @set1 = @model.set_var([], 0..20)
    @set2 = @model.set_var([], 0..20)
    @rhs = @model.set_var([], 0..20)
  
    @expect = lambda do |op1, operation_type, op2, relation_type, rhs, reif_var, negated|
      if rhs.respond_to? :bind
        expected_target = [an_instance_of(Gecode::Raw::SetVar)]
      else
        expected_target = expect_constant_set(rhs)
      end

      if reif_var.nil? and !negated
        Gecode::Raw.should_receive(:rel).once.with(
          an_instance_of(Gecode::Raw::Space), 
          an_instance_of(Gecode::Raw::SetVar), 
          operation_type,
          an_instance_of(Gecode::Raw::SetVar),
          relation_type,
          an_instance_of(Gecode::Raw::SetVar))
        Gecode::Raw.should_receive(:dom).exactly(0).times
      else
        Gecode::Raw.should_receive(:rel).once.with(
          an_instance_of(Gecode::Raw::Space), 
          an_instance_of(Gecode::Raw::SetVar), 
          operation_type,
          an_instance_of(Gecode::Raw::SetVar),
          relation_type,
          an_instance_of(Gecode::Raw::SetVar))
        Gecode::Raw.should_receive(:dom).once.with(
          an_instance_of(Gecode::Raw::Space), 
          an_instance_of(Gecode::Raw::SetVar), relation, 
          *expected_target)
      end
    end
    
    # For options spec.
    @invoke_options = lambda do |hash| 
      @set1.union(@set2).must_be.superset_of(@rhs, hash)
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      @expect.call(@set1, Gecode::Raw::SOT_SUP, @set2, Gecode::Raw::SRT_SUP, 
        @rhs, reif_var, false)
    end
  end
  
  Gecode::Constraints::Util::SET_OPERATION_TYPES.each_pair do |relation, type|
    it "should translate #{relation} with variable operands and variable rhs" do
      @expect.call(@set1, type, @set2, Gecode::Raw::SRT_SUP, @rhs, nil, false)
      @set1.send(relation, @set2).must_be.superset_of(@rhs)
      @model.solve!
    end
  end
  
  it 'should raise error if negated' do
    lambda do 
      @set1.union(@set2).must_not_be.subset_of(@rhs) 
    end.should raise_error(Gecode::MissingConstraintError)
  end
  
  it_should_behave_like 'non-reifiable set constraint'
end
