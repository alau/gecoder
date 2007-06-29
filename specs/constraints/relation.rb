require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

describe Gecode::Constraints::Int::Linear, ' (simple ones)' do
  before do
    @model = Gecode::Model.new
    @x = @model.int_var(1..2)
    @int = 4
    @y = @model.int_var(1..2)
    
    # For constraint option spec.
    @invoke_options = lambda do |hash| 
      @x.must_be.greater_than(3, hash) 
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      if reif_var.nil?
        Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
          anything, Gecode::Raw::IRT_GR, anything, 
          strength)
      else
        Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVar), Gecode::Raw::IRT_GR, anything, 
          an_instance_of(Gecode::Raw::BoolVar), strength)
      end
    end
  end
  
  Gecode::Constraints::Util::RELATION_TYPES.each_pair do |relation, type|
    it "should translate #{relation} with constant to simple relation" do
      Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
        an_instance_of(Gecode::Raw::IntVar), type, @int, Gecode::Raw::ICL_DEF)
      @x.must.send(relation, @int)
      @model.solve!
    end
  end

  Gecode::Constraints::Util::NEGATED_RELATION_TYPES.each_pair do |relation, type|
    it "should translate negated #{relation} with constant to simple relation" do
      Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
        an_instance_of(Gecode::Raw::IntVar), type, @int, Gecode::Raw::ICL_DEF)
      @x.must_not.send(relation, @int)
      @model.solve!
    end
  end

  Gecode::Constraints::Util::RELATION_TYPES.each_pair do |relation, type|
    it "should translate #{relation} with variables to simple relation" do
      Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
        an_instance_of(Gecode::Raw::IntVar), type, 
        an_instance_of(Gecode::Raw::IntVar), Gecode::Raw::ICL_DEF)
      @x.must.send(relation, @y)
      @model.solve!
    end
  end

  Gecode::Constraints::Util::NEGATED_RELATION_TYPES.each_pair do |relation, type|
    it "should translate negated #{relation} with variable to simple relation" do
      Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
        an_instance_of(Gecode::Raw::IntVar), type, 
        an_instance_of(Gecode::Raw::IntVar), Gecode::Raw::ICL_DEF)
      @x.must_not.send(relation, @y)
      @model.solve!
    end
  end

  it 'should raise error on arguments of the wrong type' do
    lambda{ @x.must == 'hello' }.should raise_error(TypeError) 
  end
  
  it_should_behave_like 'constraint with options'
end