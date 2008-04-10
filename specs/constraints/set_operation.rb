require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

describe Gecode::Constraints::Set::Operation do
  before do
    @model = Gecode::Model.new
    @set1 = @model.set_var([], 0..20)
    @set2 = @model.set_var([], 0..20)
    @rhs = @model.set_var([], 0..20)
    @model.branch_on @model.wrap_enum([@set1, @set2, @rhs])
    @constant_set = [4,9,17]
    @wrapped_constant_set = @model.wrap_enum(@constant_set)
  
    @expect = lambda do |op1, operation_type, op2, relation_type, rhs, reif_var, negated|
      op1, op2, rhs = [op1, op2, rhs].map do |expression|
        # Convert the expression to the corresponding expected class.
        if expression.respond_to? :bind
          an_instance_of(Gecode::Raw::SetVar)
        else
          an_instance_of(Gecode::Raw::IntSet)
        end
      end

      Gecode::Raw.should_receive(:rel).once.with(
        an_instance_of(Gecode::Raw::Space), op1, operation_type, op2, 
        relation_type, rhs) 
    end
    
    # For options spec.
    @invoke_options = lambda do |hash| 
      @set1.union(@set2).must_be.superset_of(@rhs, hash)
      @model.solve!
    end
    @expect_options = option_expectation do |strength, kind, reif_var|
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
    
    it "should translate #{relation} with variable operands and constant rhs" do
      @expect.call(@set1, type, @set2, Gecode::Raw::SRT_SUP, @constant_set, 
        nil, false)
      @set1.send(relation, @set2).must_be.superset_of(@constant_set)
      @model.solve!
    end
    
    it "should translate #{relation} with variable lhs, constant operand and variable rhs" do
      @expect.call(@set1, type, @constant_set, Gecode::Raw::SRT_SUP, @rhs, nil, 
        false)
      @set1.send(relation, @constant_set).must_be.superset_of(@rhs)
      @model.solve!
    end
    
    it "should translate #{relation} with variable lhs, constant operand and constant rhs" do
      @expect.call(@set1, type, @constant_set, Gecode::Raw::SRT_SUP, 
        @constant_set, nil, false)
      @set1.send(relation, @constant_set).must_be.superset_of(@constant_set)
      @model.solve!
    end
    
    it "should translate #{relation} with constant lhs, variable operand and variable rhs" do
      @expect.call(@constant_set, type, @set2, Gecode::Raw::SRT_SUP, 
        @rhs, nil, false)
      @wrapped_constant_set.send(relation, @set2).must_be.superset_of(@rhs)
      @model.solve!
    end
    
    it "should translate #{relation} with constant lhs, variable operand and constant rhs" do
      @expect.call(@constant_set, type, @set2, Gecode::Raw::SRT_SUP, 
        @constant_set, nil, false)
      @wrapped_constant_set.send(relation, @set2).must_be.superset_of(@constant_set)
      @model.solve!
    end
    
    it "should raise error for #{relation} with constant lhs, operand and rhs" do
      lambda do
        @wrapped_constant_set.send(relation, @constant_set).must_be.superset_of(
          @constant_set)
      end.should raise_error(ArgumentError)
    end
  end
  
  it 'should raise error if negated' do
    lambda do 
      @set1.union(@set2).must_not_be.subset_of(@rhs) 
    end.should raise_error(Gecode::MissingConstraintError)
  end
  
  it 'should constrain the sets according to the operation (variable operands, variable rhs)' do
    @set1.intersection(@set2).must == @rhs
    @rhs.must == @constant_set
    @model.solve!.should_not be_nil
    (@set1.value.to_a & @set2.value.to_a).sort.should == @constant_set 
  end
  
  it 'should constrain the sets according to the operation (variable operands, constant rhs)' do
    @set1.intersection(@set2).must == @constant_set
    @model.solve!.should_not be_nil
    (@set1.value.to_a & @set2.value.to_a).sort.should == @constant_set 
  end
  
  it 'should constrain the sets according to the operation (variable lhs, constant operand and rhs)' do
    @set1.union(@constant_set).must == @constant_set
    @model.solve!.should_not be_nil
    (@set1.value.to_a + @constant_set).uniq.sort.should == @constant_set.sort
  end
  
  it 'should constrain the sets according to the operation (variable lhs and rhs, constant operand)' do
    @set1.union(@constant_set).must == @rhs
    @model.solve!.should_not be_nil
    (@set1.value.to_a + @constant_set).uniq.sort.should == @rhs.value.to_a.sort 
  end
  
  it 'should constrain the sets according to the operation (constant lhs, variable operand and rhs)' do
    @wrapped_constant_set.minus(@set2).must == @rhs
    @model.solve!.should_not be_nil
    (@constant_set - @set2.value.to_a).sort.should == @rhs.value.sort
  end
  
  it 'should constrain the sets according to the operation (constant lhs and rhs, variable operand)' do
    @wrapped_constant_set.minus(@set2).must == @constant_set
    @model.solve!.should_not be_nil
    (@constant_set - @set2.value.to_a).sort.should == @constant_set
  end
  
  it_should_behave_like 'non-reifiable set constraint'
end

describe 'set enum operation constraint', :shared => true do
  include GecodeR::Specs::SetHelper
  
  before do
    @expect = lambda do |enum, operation_type, relation, rhs, reif_var, negated|
      if rhs.respond_to? :bind
        expected_target = [an_instance_of(Gecode::Raw::SetVar)]
        relation_constraint = :rel
      else
        expected_target = expect_constant_set(rhs)
        relation_constraint = :dom
      end

      if reif_var.nil?
        if !negated and relation == Gecode::Raw::IRT_EQ and 
            !rhs.kind_of? Enumerable
          Gecode::Raw.should_receive(:rel).once.with(
            an_instance_of(Gecode::Raw::Space), operation_type, 
            an_instance_of(Gecode::Raw::SetVarArray), 
            *expected_target)
          Gecode::Raw.should_receive(:dom).exactly(0).times
        else
          if relation_constraint == :rel
            Gecode::Raw.should_receive(:rel).twice
          else
            Gecode::Raw.should_receive(:rel).once.with(
              an_instance_of(Gecode::Raw::Space), operation_type, 
              an_instance_of(Gecode::Raw::SetVarArray), 
              an_instance_of(Gecode::Raw::SetVar))
            Gecode::Raw.should_receive(relation_constraint).at_most(:twice)
          end
        end
      else
        if relation_constraint == :rel
          Gecode::Raw.should_receive(:rel).twice
        else
          Gecode::Raw.should_receive(:rel).once.with(
            an_instance_of(Gecode::Raw::Space), operation_type, 
            an_instance_of(Gecode::Raw::SetVarArray), 
            an_instance_of(Gecode::Raw::SetVar))
          expected_target << an_instance_of(Gecode::Raw::BoolVar)
          Gecode::Raw.should_receive(relation_constraint).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::SetVar), relation, *expected_target)
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
      @expect.call(@sets, @operation_type, relation, target, nil, negated)
    end
    
    # For options spec.
    @invoke_options = lambda do |hash| 
      @stub.must_be.superset_of(@rhs, hash)
      @model.solve!
    end
    @expect_options = option_expectation do |strength, kind, reif_var|
      @expect.call(@sets, @operation_type, Gecode::Raw::SRT_SUP, @rhs, 
        reif_var, false)
    end
  end
  
  it_should_behave_like 'reifiable set constraint'
  it_should_behave_like 'composite set constraint'
end

describe Gecode::Constraints::SetEnum::Operation, ' (union)' do
  before do
    @model = Gecode::Model.new
    @sets = @model.set_var_array(10, [], 0..20)
    @target = @rhs = @model.set_var([], 0..20)
    @model.branch_on @sets
    
    @stub = @sets.union
    @operation_type = Gecode::Raw::SOT_UNION
  end

  it 'should constrain the union of the sets' do
    @sets.union.must_be.subset_of [1,4,17]
    @sets.union.must_be.superset_of 1
    @model.solve!.should_not be_nil
    union = @sets.values.inject([]){ |union, set| union += set.to_a }.uniq
    union.should include(1)
    (union - [1,4,17]).should be_empty
  end
  
  it_should_behave_like 'set enum operation constraint'
end

describe Gecode::Constraints::SetEnum::Operation, ' (intersection)' do
  before do
    @model = Gecode::Model.new
    @sets = @model.set_var_array(10, [], 0..20)
    @target = @rhs = @model.set_var([], 0..20)
    @model.branch_on @sets
    
    @stub = @sets.intersection
    @operation_type = Gecode::Raw::SOT_INTER
  end

  it 'should constrain the intersection of the sets' do
    @sets.intersection.must_be.subset_of [1,4,17]
    @sets.intersection.must_be.superset_of [1]
    @model.solve!.should_not be_nil
    intersection = @sets.values.inject(nil) do |intersection, set|
      next set.to_a if intersection.nil?
      intersection &= set.to_a
    end.uniq
    intersection.should include(1)
    (intersection - [1,4,17]).should be_empty
  end
  
  it_should_behave_like 'set enum operation constraint'
end

describe Gecode::Constraints::SetEnum::Operation, ' (disjoint union)' do
  before do
    @model = Gecode::Model.new
    @sets = @model.set_var_array(10, [], 0..20)
    @target = @rhs = @model.set_var([], 0..20)
    @model.branch_on @sets
    
    @stub = @sets.disjoint_union
    @operation_type = Gecode::Raw::SOT_DUNION
  end

  it 'should constrain the disjoint union of the sets' do
    @sets.disjoint_union.must_be.subset_of [1,4,17]
    @sets.disjoint_union.must_be.superset_of [1]
    @model.solve!.should_not be_nil
    disjoint_union = @sets.values.inject([]) do |union, set|
      intersection = union & set.to_a
      union += set.to_a - intersection
    end.uniq
    disjoint_union.should include(1)
    (disjoint_union - [1,4,17]).should be_empty
  end
  
  it_should_behave_like 'set enum operation constraint'
end
