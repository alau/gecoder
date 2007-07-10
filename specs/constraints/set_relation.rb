require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

describe Gecode::Constraints::Set::Relation do
  include GecodeR::Specs::SetHelper

  before do
    @model = Gecode::Model.new
    @set = @model.set_var([0], 0..3)
    @set2 = @model.set_var([1], 0..3)
    
    @expect = lambda do |relation_type, rhs, reif_var, negated|
      if reif_var.nil? and !negated
        Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
          @set.bind, relation_type, @set2.bind)
      else
        Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
          @set.bind, relation_type, @set2.bind, 
          an_instance_of(Gecode::Raw::BoolVar))
      end
    end
    
    # For options spec.
    @invoke_options = lambda do |hash| 
      @set.must_be.superset_of(@set2, hash)
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      @expect.call(Gecode::Raw::SRT_SUP, @set2, reif_var, false)
    end
  end
  
  Gecode::Constraints::Util::SET_RELATION_TYPES.each_pair do |relation, type|
    next if relation == :==
  
    it "should translate #{relation} with set to relation constraint" do
      @expect.call(type, @set2, nil, false)
      @set.must.send(relation, @set2)
      @model.solve!
    end
  
    it "should translate negated #{relation} with set to relation constraint" do
      @expect.call(type, @set2, nil, true)
      @set.must_not.send(relation, @set2)
      @model.solve!
    end
  end
  
  it_should_behave_like 'constraint with options'
end

describe Gecode::Constraints::Set::Relation, ' (equality)' do
  include GecodeR::Specs::SetHelper

  before do
    @model = Gecode::Model.new
    @set = @model.set_var([0], 0..1)
    @set2 = @model.set_var([1], 0..1)
    
    @expect = lambda do |relation_type, rhs, reif_var|
      if reif_var.nil?
        Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
          @set.bind, relation_type, @set2.bind)
      else
        Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
          @set.bind, relation_type, @set2.bind, 
          an_instance_of(Gecode::Raw::BoolVar))
      end
    end
    
    # For options spec.
    @invoke_options = lambda do |hash| 
      @set.must_be.equal_to(@set2, hash)
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      @expect.call(Gecode::Raw::SRT_EQ, @set2, reif_var)
    end
  end
  
  it 'should translate equality with set to relation constraint' do
    @expect.call(Gecode::Raw::SRT_EQ, @set2, nil)
    @set.must == @set2
    @model.solve!
  end
  
  it 'should translate negated equality with set to domain constraint' do
    @expect.call(Gecode::Raw::SRT_NQ, @set2, nil)
    @set.must_not == @set2
    @model.solve!
  end
  
  it 'should constrain sets to be equality when not negated' do
    @set.must == @set2
    @model.solve!
    @set.should have_bounds(0..1, 0..1)
    @set2.should have_bounds(0..1, 0..1)
  end
  
  it 'should constrain sets to not be equal when negated' do
    @set.must_not == @set2
    union = @model.set_var([0, 1], [0, 1])
    @set.must_not == union
    @set2.must_not == union
    @model.solve!
    @set.should have_bounds([0], [0])
    @set2.should have_bounds([1], [1])
  end
  
  it_should_behave_like 'constraint with options'
end