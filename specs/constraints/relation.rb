require File.dirname(__FILE__) + '/../spec_helper'

describe Gecode::FreeIntVar, ' (relation constraints)' do
  before do
    @model = Gecode::Model.new
    @x = @model.int_var(1..2)
    @int = 4
  end
  
  relation_types = {
    :== => Gecode::Raw::IRT_EQ,
    :<= => Gecode::Raw::IRT_LQ,
    :<  => Gecode::Raw::IRT_LE,
    :>= => Gecode::Raw::IRT_GQ,
    :>  => Gecode::Raw::IRT_GR
  }.each_pair do |relation, type|
    it "should translate #{relation} with constant to simple relation" do
      Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
        an_instance_of(Gecode::Raw::IntVar), type, @int, Gecode::Raw::ICL_DEF)
      @x.must.send(relation, @int)
    end
  end

  negated_relation_types = {
        :== => Gecode::Raw::IRT_NQ,
        :<= => Gecode::Raw::IRT_GR,
        :<  => Gecode::Raw::IRT_GQ,
        :>= => Gecode::Raw::IRT_LE,
        :>  => Gecode::Raw::IRT_LQ
  }.each_pair do |relation, type|
    it "should translate negated #{relation} with constant to simple relation" do
      Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
        an_instance_of(Gecode::Raw::IntVar), type, @int, Gecode::Raw::ICL_DEF)
      @x.must_not.send(relation, @int)
    end
  end

  it 'should raise error on arguments of the wrong type' do
    lambda{ @x.must == 'hello' }.should raise_error(TypeError) 
  end
end