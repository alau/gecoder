require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

describe Gecode::Constraints::Set::Domain do
  include GecodeR::Specs::SetHelper

  before do
    @model = Gecode::Model.new
    @glb = [0]
    @lub = 0..3
    @set = @model.set_var(@glb, @lub)
    @range = 0..1
    @non_range = [0, 2]
    @singleton = 0
    
    @expect = lambda do |relation_type, rhs, reif_var, negated|
      if reif_var.nil? and !negated
        Gecode::Raw.should_receive(:dom).once.with(@model.active_space, 
          @set.bind, relation_type, *expect_constant_set(rhs))
      else
        params = [@model.active_space, @set.bind, relation_type]
        params << expect_constant_set(rhs)
        params << an_instance_of(Gecode::Raw::BoolVar)
        Gecode::Raw.should_receive(:dom).once.with(*params.flatten)
      end
    end
    
    # For options spec.
    @invoke_options = lambda do |hash| 
      @set.must_be.superset_of(@non_range, hash)
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      @expect.call(Gecode::Raw::SRT_SUP, @non_range, reif_var, false)
    end
  end
  
  Gecode::Constraints::Util::SET_RELATION_TYPES.each_pair do |relation, type|
    next if relation == :==
  
    it 'should translate equality with constant range to domain constraint' do
      @expect.call(type, @range, nil, false)
      @set.must.send(relation, @range)
      @model.solve!
    end
    
    it 'should translate equality with constant non-range to domain constraint' do
      @expect.call(type, @non_range, nil, false)
      @set.must.send(relation, @non_range)
      @model.solve!
    end
    
    it 'should translate equality with constant singleton to domain constraint' do
      @expect.call(type, @singleton, nil, false)
      @set.must.send(relation, @singleton)
      @model.solve!
    end
  
    it 'should translate negated equality with constant range to domain constraint' do
      @expect.call(type, @range, nil, true)
      @set.must_not.send(relation, @range)
      @model.solve!
    end
    
    it 'should translate negated equality with constant non-range to domain constraint' do
      @expect.call(type, @non_range, nil, true)
      @set.must_not.send(relation, @non_range)
      @model.solve!
    end
    
    it 'should translate negated equality with constant singleton to domain constraint' do
      @expect.call(type, @singleton, nil, true)
      @set.must_not.send(relation, @singleton)
      @model.solve!
    end
  end
  
  it_should_behave_like 'constraint with options'
end

describe Gecode::Constraints::Set::Domain, ' (equality)' do
  include GecodeR::Specs::SetHelper

  before do
    @model = Gecode::Model.new
    @glb = [0]
    @lub = 0..3
    @set = @model.set_var(@glb, @lub)
    @range = 0..1
    @non_range = [0, 2]
    @singleton = 0
    
    @expect = lambda do |relation_type, rhs, reif_var|
      if reif_var.nil?
        Gecode::Raw.should_receive(:dom).once.with(@model.active_space, 
          @set.bind, relation_type, *expect_constant_set(rhs))
      else
        params = [@model.active_space, @set.bind, relation_type]
        params << expect_constant_set(rhs)
        params << an_instance_of(Gecode::Raw::BoolVar)
        Gecode::Raw.should_receive(:dom).once.with(*params.flatten)
      end
    end
    
    # For options spec.
    @invoke_options = lambda do |hash| 
      @set.must_be.equal_to(@non_range, hash)
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      @expect.call(Gecode::Raw::SRT_EQ, @non_range, reif_var)
    end
  end
  
  it 'should translate equality with constant range to domain constraint' do
    @expect.call(Gecode::Raw::SRT_EQ, @range, nil)
    @set.must == @range
    @model.solve!
  end
  
  it 'should translate equality with constant non-range to domain constraint' do
    @expect.call(Gecode::Raw::SRT_EQ, @non_range, nil)
    @set.must == @non_range
    @model.solve!
  end
  
  it 'should translate equality with constant singleton to domain constraint' do
    @expect.call(Gecode::Raw::SRT_EQ, @singleton, nil)
    @set.must == @singleton
    @model.solve!
  end
  
  it 'should translate negated equality with constant range to domain constraint' do
    @expect.call(Gecode::Raw::SRT_NQ, @range, nil)
    @set.must_not == @range
    @model.solve!
  end
  
  it 'should translate negated equality with constant non-range to domain constraint' do
    @expect.call(Gecode::Raw::SRT_NQ, @non_range, nil)
    @set.must_not == @non_range
    @model.solve!
  end
  
  it 'should translate negated equality with constant singleton to domain constraint' do
    @expect.call(Gecode::Raw::SRT_NQ, @singleton, nil)
    @set.must_not == @singleton
    @model.solve!
  end
  
  it 'should constrain the domain with equality' do
    @set.must == @singleton
    @model.solve!
    @set.should be_assigned
    @set.should include(@singleton)
    @set.size.should == 1
  end
  
  it 'should constrain the domain with inequality' do
    @set.must_not == @singleton
    @model.solve!.should be_nil
  end
  
  it_should_behave_like 'constraint with options'
end