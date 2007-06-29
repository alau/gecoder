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
    @expect = lambda do |element, relation, target, strength, reif_var|
      target = target.bind if target.respond_to? :bind
      element = element.bind if element.respond_to? :bind
      if reif_var.nil?
        Gecode::Raw.should_receive(:count).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVarArray), 
          element, relation, target, strength)
      else
        Gecode::Raw.should_receive(:count).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVarArray), 
          element, Gecode::Raw::IRT_EQ,
          an_instance_of(Gecode::Raw::IntVar), strength)
        Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVar), relation,
          target, reif_var.bind, strength)
      end
    end
    
    # For constraint option spec.
    @invoke_options = lambda do |hash| 
      @list.count(@element).must_be.greater_than(@target, hash) 
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      @expect.call(@element, Gecode::Raw::IRT_GR, @target, strength, reif_var)
    end
  end

  situations = {
    'variable element and target' => [@element, @target],
    'variable element and constant target' => [@element, 2],
    'constant element and variable target' => [1, @target],
    'constant element and constant target' => [1, 2]
  }.each_pair do |description, element_and_target|
    element, target = element_and_target
    Gecode::Constraints::Util::RELATION_TYPES.each_pair do |relation, type|
      it "should translate #{relation} with #{description}" do
        @expect.call(@element, type, @target, Gecode::Raw::ICL_DEF, nil)
        @list.count(@element).must.send(relation, @target)
        @model.solve!
      end
    end
    Gecode::Constraints::Util::NEGATED_RELATION_TYPES.each_pair do |relation, type|
      it "should translate negated #{relation} with #{description}" do
        @expect.call(@element, type, @target, Gecode::Raw::ICL_DEF, nil)
        @list.count(@element).must_not.send(relation, @target)
        @model.solve!
      end
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
    @model.solve!.should be_nil
  end
  
  it_should_behave_like 'constraint with options'
end