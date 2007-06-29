require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

class ArithmeticSampleProblem < Gecode::Model
  attr :numbers
  attr :var
  
  def initialize
    @numbers = int_var_array(4, 0..9)
    @var = int_var(0..9)
    branch_on @numbers
  end
end

describe Gecode::Constraints::IntEnum::Arithmetic, ' (max)' do
  before do
    @model = ArithmeticSampleProblem.new
    @numbers = @model.numbers
    @var = @model.var
    
    # Creates an expectation corresponding to the specified input.
    @expect = lambda do |relation, rhs, strength, reif_var|
      rhs = rhs.bind if rhs.respond_to? :bind
      if reif_var.nil?
        Gecode::Raw.should_receive(:max).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVarArray), 
          an_instance_of(Gecode::Raw::IntVar), an_instance_of(Fixnum))
        Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVar), relation, rhs, strength)
      else
        Gecode::Raw.should_receive(:max).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVarArray), 
          an_instance_of(Gecode::Raw::IntVar), an_instance_of(Fixnum))
        Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVar), relation, rhs, reif_var.bind,
          strength)
      end
    end
    
    # For constraint option spec.
    @invoke_options = lambda do |hash| 
      @numbers.max.must_be.greater_than(@var, hash) 
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      @expect.call(Gecode::Raw::IRT_GR, @var, strength, reif_var)
    end
  end
  
  situations = {
    'variable bound' => nil,
    'constant bound' => 5
  }.each_pair do |description, bound|
    Gecode::Constraints::Util::RELATION_TYPES.each_pair do |relation, type|
      it "should translate #{relation} with #{description}" do
        bound = @var if bound.nil?
        @expect.call(type, bound, Gecode::Raw::ICL_DEF, nil)
        @numbers.max.must.send(relation, bound)
        @model.solve!
      end
    end
    Gecode::Constraints::Util::NEGATED_RELATION_TYPES.each_pair do |relation, type|
      it "should translate negated #{relation} with #{description}" do
        bound = @var if bound.nil?
        @expect.call(type, bound, Gecode::Raw::ICL_DEF, nil)
        @numbers.max.must_not.send(relation, bound)
        @model.solve!
      end
    end
  end
  
  it 'should raise error if the right hand side is of the wrong type' do
    lambda{ @numbers.max.must == 'hello' }.should raise_error(TypeError) 
  end
  
  it 'should constrain the maximum value' do
    @numbers.max.must > 5
    @model.solve!.numbers.map{ |n| n.val }.max.should > 5
  end
  
  it_should_behave_like 'constraint with options'
end

describe Gecode::Constraints::IntEnum::Arithmetic, ' (min)' do
  before do
    @model = ArithmeticSampleProblem.new
    @numbers = @model.numbers
    @var = @model.var
    
    # Creates an expectation corresponding to the specified input.
    @expect = lambda do |relation, rhs, strength, reif_var|
      rhs = rhs.bind if rhs.respond_to? :bind
      if reif_var.nil?
        Gecode::Raw.should_receive(:min).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVarArray), 
          an_instance_of(Gecode::Raw::IntVar), an_instance_of(Fixnum))
        Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVar), relation, rhs, strength)
      else
        Gecode::Raw.should_receive(:min).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVarArray), 
          an_instance_of(Gecode::Raw::IntVar), an_instance_of(Fixnum))
        Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVar), relation, rhs, reif_var.bind,
          strength)
      end
    end
    
    # For constraint option spec.
    @invoke_options = lambda do |hash| 
      @numbers.min.must_be.greater_than(@var, hash) 
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      @expect.call(Gecode::Raw::IRT_GR, @var, strength, reif_var)
    end
  end
  
  situations = {
    'variable bound' => nil,
    'constant bound' => 5
  }.each_pair do |description, bound|
    Gecode::Constraints::Util::RELATION_TYPES.each_pair do |relation, type|
      it "should translate #{relation} with #{description}" do
        bound = @var if bound.nil?
        @expect.call(type, bound, Gecode::Raw::ICL_DEF, nil)
        @numbers.min.must.send(relation, bound)
        @model.solve!
      end
    end
    Gecode::Constraints::Util::NEGATED_RELATION_TYPES.each_pair do |relation, type|
      it "should translate negated #{relation} with #{description}" do
        bound = @var if bound.nil?
        @expect.call(type, bound, Gecode::Raw::ICL_DEF, nil)
        @numbers.min.must_not.send(relation, bound)
        @model.solve!
      end
    end
  end
  
  it 'should raise error if the right hand side is of the wrong type' do
    lambda{ @numbers.min.must == 'hello' }.should raise_error(TypeError) 
  end
  
  it 'should constrain the minimum value' do
    @numbers.min.must > 5
    @model.solve!.numbers.map{ |n| n.val }.min.should > 5
  end
  
  it_should_behave_like 'constraint with options'
end