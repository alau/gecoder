require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

class CountSampleProblem < Gecode::Model
  attr :list
  attr :element
  attr :target
  
  def initialize
    @list = int_var_array(4, 0..3)
    @element = int_var(0..3)
    @target = int_var(0..4)
    branch_on @list
  end
end

describe Gecode::Constraints::IntEnum::Count do
  before do
    @model = CountSampleProblem.new
    @list = @model.list
    @element = @model.element
    @target = @model.target
    
    # Creates an expectation corresponding to the specified input.
    @expect = lambda do |element, relation, target, strength, kind, reif_var|
      @model.allow_space_access do
        target = an_instance_of(Gecode::Raw::IntVar) if target.respond_to? :bind
        element = an_instance_of(Gecode::Raw::IntVar) if element.respond_to? :bind
        if reif_var.nil?
          Gecode::Raw.should_receive(:count).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVarArray), 
            element, relation, target, strength, kind)
        else
          Gecode::Raw.should_receive(:count).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVarArray), 
            element, Gecode::Raw::IRT_EQ,
            an_instance_of(Gecode::Raw::IntVar), strength, kind)
          Gecode::Raw.should_receive(:rel).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVar), relation,
            target, an_instance_of(Gecode::Raw::BoolVar), strength, kind)
        end
      end
    end
    
    # For constraint option spec.
    @invoke_options = lambda do |hash| 
      @list.count(@element).must_be.greater_than(@target, hash) 
      @model.solve!
    end
    @expect_options = option_expectation do |strength, kind, reif_var|
      @expect.call(@element, Gecode::Raw::IRT_GR, @target, strength, 
        kind, reif_var)
    end
  end

  # Various situations that must be handled (4*2 in total). This was originally
  # written without the repetition (r269), but that interfered with the spec 
  # somehow.

  Gecode::Constraints::Util::RELATION_TYPES.each_pair do |relation, type|
    it "should translate #{relation} with variable element and target" do
      @expect.call(@element, type, @target, Gecode::Raw::ICL_DEF,
        Gecode::Raw::PK_DEF, nil)
      @list.count(@element).must.send(relation, @target)
      @model.solve!
    end
  end
  Gecode::Constraints::Util::NEGATED_RELATION_TYPES.each_pair do |relation, type|
    it "should translate negated #{relation} with variable element and target" do
      @expect.call(@element, type, @target, Gecode::Raw::ICL_DEF, 
        Gecode::Raw::PK_DEF, nil)
      @list.count(@element).must_not.send(relation, @target)
      @model.solve!
    end
  end
  
  Gecode::Constraints::Util::RELATION_TYPES.each_pair do |relation, type|
    it "should translate #{relation} with variable element and constant target" do
      @expect.call(@element, type, 2, Gecode::Raw::ICL_DEF, 
        Gecode::Raw::PK_DEF, nil)
      @list.count(@element).must.send(relation, 2)
      @model.solve!
    end
  end
  Gecode::Constraints::Util::NEGATED_RELATION_TYPES.each_pair do |relation, type|
    it "should translate negated #{relation} with variable element and constant target" do
      @expect.call(@element, type, 2, Gecode::Raw::ICL_DEF, 
        Gecode::Raw::PK_DEF, nil)
      @list.count(@element).must_not.send(relation, 2)
      @model.solve!
    end
  end
  
  Gecode::Constraints::Util::RELATION_TYPES.each_pair do |relation, type|
    it "should translate #{relation} with constant element and constant target" do
      @expect.call(1, type, 2, Gecode::Raw::ICL_DEF, Gecode::Raw::PK_DEF, nil)
      @list.count(1).must.send(relation, 2)
      @model.solve!
    end
  end
  Gecode::Constraints::Util::NEGATED_RELATION_TYPES.each_pair do |relation, type|
    it "should translate negated #{relation} with constant element and constant target" do
      @expect.call(1, type, 2, Gecode::Raw::ICL_DEF, Gecode::Raw::PK_DEF, nil)
      @list.count(1).must_not.send(relation, 2)
      @model.solve!
    end
  end

  Gecode::Constraints::Util::RELATION_TYPES.each_pair do |relation, type|
    it "should translate #{relation} with constant element and variable target" do
      @expect.call(1, type, @target, Gecode::Raw::ICL_DEF, 
        Gecode::Raw::PK_DEF, nil)
      @list.count(1).must.send(relation, @target)
      @model.solve!
    end
  end
  Gecode::Constraints::Util::NEGATED_RELATION_TYPES.each_pair do |relation, type|
    it "should translate negated #{relation} with constant element and variable target" do
      @expect.call(1, type, @target, Gecode::Raw::ICL_DEF, 
        Gecode::Raw::PK_DEF, nil)
      @list.count(1).must_not.send(relation, @target)
      @model.solve!
    end
  end

  it 'should raise error if the target is of the wrong type' do
    lambda{ @list.count(@element).must == 'hello' }.should raise_error(
      TypeError) 
  end
  
  it 'should raise error on element is of the wrong type' do
    lambda{ @list.count('foo').must == @target }.should raise_error(
      TypeError)
  end
  
  it 'should constrain the count' do
    @list.must_be.distinct
    @list.count(0).must <= 0
    lambda{ @model.solve! }.should raise_error(Gecode::NoSolutionError)
  end
  
  it_should_behave_like 'reifiable constraint'
end
