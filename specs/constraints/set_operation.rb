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
  
    @expect = lambda do |op1, operation_type, op2, relation_type, rhs, reif_var, negated|
      if rhs.respond_to? :bind
        expected_target = an_instance_of(Gecode::Raw::SetVar)
      else
        expected_target = an_instance_of(Gecode::Raw::IntSet)
      end
      if op2.respond_to? :bind
        expected_op2 = an_instance_of(Gecode::Raw::SetVar)
      else
        expected_op2 = an_instance_of(Gecode::Raw::IntSet)
      end

      Gecode::Raw.should_receive(:rel).once.with(
        an_instance_of(Gecode::Raw::Space), 
        an_instance_of(Gecode::Raw::SetVar), 
        operation_type,
        expected_op2,
        relation_type,
        expected_target)
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
  
  it_should_behave_like 'non-reifiable set constraint'
end
