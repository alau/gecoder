require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

# Requires @expect, @model, @stub, @target.
describe 'connection constraint', :shared => true do
  before do
    @invoke = lambda do |rhs| 
      @stub.must == rhs 
      @model.solve!
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
      @expect.call(relation, target, Gecode::Raw::ICL_DEF, nil, negated)
    end
    
    # For options spec.
    @invoke_options = lambda do |hash|
      @stub.must_be.less_than_or_equal_to(17, hash)
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      @expect.call(Gecode::Raw::IRT_LQ, 17, strength, reif_var, false)
    end
  end
  
  it_should_behave_like 'constraint with options'
  it_should_behave_like 'composite constraint'
end

describe Gecode::Constraints::Set::Connection, ' (min)' do
  before do
    @model = Gecode::Model.new
    @set = @model.set_var([], 0..9)
    @target = @var = @model.int_var(0..10)
    @model.branch_on @model.wrap_enum([@set])
    @stub = @set.min
    
    @expect = lambda do |relation, rhs, strength, reif_var, negated|
      rhs = rhs.bind if rhs.respond_to? :bind
      if reif_var.nil?
        if !negated and relation == Gecode::Raw::IRT_EQ and 
            rhs.kind_of? Gecode::Raw::IntVar 
          Gecode::Raw.should_receive(:min).once.with(
            @model.active_space, @set.bind, rhs)
          Gecode::Raw.should_receive(:rel).exactly(0).times
        else
          Gecode::Raw.should_receive(:min).once.with(
            @model.active_space, @set.bind, an_instance_of(Gecode::Raw::IntVar))
          Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
            an_instance_of(Gecode::Raw::IntVar), relation, rhs, 
            strength)
        end
      else
        Gecode::Raw.should_receive(:min).once.with(@model.active_space, 
          @set.bind, an_instance_of(Gecode::Raw::IntVar))
        Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVar), relation, rhs, reif_var.bind,
          strength)
      end
    end
  end
  
  it 'should constrain the min of a set' do
    @set.min.must == @var
    @model.solve!
    @set.glb_min.should == @var.val
  end
  
  it_should_behave_like 'connection constraint'
end

describe Gecode::Constraints::Set::Connection, ' (max)' do
  before do
    @model = Gecode::Model.new
    @set = @model.set_var([], 0..9)
    @target = @var = @model.int_var(0..10)
    @model.branch_on @model.wrap_enum([@set])
    @stub = @set.max
    
    @expect = lambda do |relation, rhs, strength, reif_var, negated|
      rhs = rhs.bind if rhs.respond_to? :bind
      if reif_var.nil?
        if !negated and relation == Gecode::Raw::IRT_EQ and 
            rhs.kind_of? Gecode::Raw::IntVar 
          Gecode::Raw.should_receive(:max).once.with(
            @model.active_space, @set.bind, rhs)
          Gecode::Raw.should_receive(:rel).exactly(0).times
        else
          Gecode::Raw.should_receive(:max).once.with(
            @model.active_space, @set.bind, an_instance_of(Gecode::Raw::IntVar))
          Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
            an_instance_of(Gecode::Raw::IntVar), relation, rhs, 
            strength)
        end
      else
        Gecode::Raw.should_receive(:max).once.with(@model.active_space, 
          @set.bind, an_instance_of(Gecode::Raw::IntVar))
        Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVar), relation, rhs, reif_var.bind,
          strength)
      end
    end
  end
  
  it 'should constrain the min of a set' do
    @set.max.must == @var
    @model.solve!
    @set.glb_max.should == @var.val
  end
  
  it_should_behave_like 'connection constraint'
end
