require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

class ArithmeticSampleProblem < Gecode::Model
  attr :numbers
  attr :var
  attr :var2
  attr :var3
  
  def initialize
    @numbers = int_var_array(4, 0..9)
    @var = int_var(-9..9)
    @var2 = int_var(0..9)
    @var3 = int_var(0..9)
    branch_on @numbers
    branch_on wrap_enum([@var, @var2, @var3])
  end
end

# Requires @stub, @target, @model and @expect.
describe 'arithmetic constraint', :shared => true do
  before do
    # For constraint option spec.
    @invoke_options = lambda do |hash| 
      @stub.must_be.greater_than(@target, hash) 
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      @expect.call(Gecode::Raw::IRT_GR, @target, strength, reif_var, false)
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
  end
  
  it 'should translate reification when using equality' do
    bool_var = @model.bool_var
    @expect.call(Gecode::Raw::IRT_EQ, @target, Gecode::Raw::ICL_DEF, bool_var, 
      false)
    @stub.must_be.equal_to(@target, :reify => bool_var)
    @model.solve!
  end
  
  it_should_behave_like 'composite constraint'
  it_should_behave_like 'constraint with options'
end

describe Gecode::Constraints::IntEnum::Arithmetic, ' (max)' do
  before do
    @model = ArithmeticSampleProblem.new
    @numbers = @model.numbers
    @target = @var = @model.var
    @stub = @numbers.max
    
    # Creates an expectation corresponding to the specified input.
    @expect = lambda do |relation, rhs, strength, reif_var, negated|
      @model.allow_space_access do
        rhs = rhs.bind if rhs.respond_to? :bind
        if reif_var.nil?
          if !negated and relation == Gecode::Raw::IRT_EQ and 
              rhs.kind_of? Gecode::Raw::IntVar 
            Gecode::Raw.should_receive(:max).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVarArray), rhs, strength)
            Gecode::Raw.should_receive(:rel).exactly(0).times
          else
            Gecode::Raw.should_receive(:max).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVarArray), 
              an_instance_of(Gecode::Raw::IntVar), strength)
            Gecode::Raw.should_receive(:rel).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVar), relation, rhs, strength)
          end
        else
          Gecode::Raw.should_receive(:max).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVarArray), 
            an_instance_of(Gecode::Raw::IntVar), strength)
          Gecode::Raw.should_receive(:rel).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVar), relation, rhs, reif_var.bind,
            strength)
        end
      end
    end
  end
  
  it 'should constrain the maximum value' do
    @numbers.max.must > 5
    @model.solve!.numbers.map{ |n| n.value }.max.should > 5
  end
  
  it_should_behave_like 'arithmetic constraint'
end

describe Gecode::Constraints::IntEnum::Arithmetic, ' (min)' do
  before do
    @model = ArithmeticSampleProblem.new
    @numbers = @model.numbers
    @target = @var = @model.var
    @stub = @numbers.min
    
    # Creates an expectation corresponding to the specified input.
    @expect = lambda do |relation, rhs, strength, reif_var, negated|
      @model.allow_space_access do
        rhs = rhs.bind if rhs.respond_to? :bind
       if reif_var.nil?
          if !negated and relation == Gecode::Raw::IRT_EQ and 
              rhs.kind_of? Gecode::Raw::IntVar 
            Gecode::Raw.should_receive(:min).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVarArray), rhs, strength)
            Gecode::Raw.should_receive(:rel).exactly(0).times
          else
            Gecode::Raw.should_receive(:min).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVarArray), 
              an_instance_of(Gecode::Raw::IntVar), strength)
            Gecode::Raw.should_receive(:rel).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVar), relation, rhs, strength)
          end
        else
          Gecode::Raw.should_receive(:min).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVarArray), 
            an_instance_of(Gecode::Raw::IntVar), strength)
          Gecode::Raw.should_receive(:rel).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVar), relation, rhs, reif_var.bind,
            strength)
        end
      end
    end
  end
  
  it 'should constrain the minimum value' do
    @numbers.min.must > 5
    @model.solve!.numbers.map{ |n| n.value }.min.should > 5
  end
  
  it_should_behave_like 'arithmetic constraint'
end

describe Gecode::Constraints::Int::Arithmetic, ' (abs)' do
  before do
    @model = ArithmeticSampleProblem.new
    @var = @model.var
    @target = @model.var2
    @stub = @var.abs
    
    # Creates an expectation corresponding to the specified input.
    @expect = lambda do |relation, rhs, strength, reif_var, negated|
      @model.allow_space_access do
        rhs = rhs.bind if rhs.respond_to? :bind
        if reif_var.nil?
          if !negated and relation == Gecode::Raw::IRT_EQ and 
              rhs.kind_of? Gecode::Raw::IntVar 
            Gecode::Raw.should_receive(:abs).once.with(
              an_instance_of(Gecode::Raw::Space),
              @var.bind, rhs, strength)
            Gecode::Raw.should_receive(:rel).exactly(0).times
          else
            Gecode::Raw.should_receive(:abs).once.with(
              an_instance_of(Gecode::Raw::Space),
              @var.bind, an_instance_of(Gecode::Raw::IntVar), strength)
            Gecode::Raw.should_receive(:rel).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVar), relation, rhs, strength)
          end
        else
          Gecode::Raw.should_receive(:abs).once.with(
            an_instance_of(Gecode::Raw::Space),
            @var.bind, an_instance_of(Gecode::Raw::IntVar), strength)
          Gecode::Raw.should_receive(:rel).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVar), relation, rhs, 
            an_instance_of(Gecode::Raw::BoolVar), strength)
        end
      end
    end
  end
  
  it 'should constrain the absolute value' do
    @var.must < 0
    @var.abs.must == 5
    @model.solve!.var.value.should == -5
  end
  
  it_should_behave_like 'arithmetic constraint'
end

describe Gecode::Constraints::Int::Arithmetic, ' (multiplication)' do
  before do
    @model = ArithmeticSampleProblem.new
    @var = @model.var
    @var2 = @model.var2
    @stub = @var * @var2
    @target = @model.var3
    
    # Creates an expectation corresponding to the specified input.
    @expect = lambda do |relation, rhs, strength, reif_var, negated|
      @model.allow_space_access do
        rhs = rhs.bind if rhs.respond_to? :bind
        if reif_var.nil?
          if !negated and relation == Gecode::Raw::IRT_EQ and 
              rhs.kind_of? Gecode::Raw::IntVar 
            Gecode::Raw.should_receive(:mult).once.with(
              an_instance_of(Gecode::Raw::Space),
              @var.bind, @var2.bind, rhs, strength)
            Gecode::Raw.should_receive(:rel).exactly(0).times
          else
            Gecode::Raw.should_receive(:mult).once.with(
              an_instance_of(Gecode::Raw::Space),
              @var.bind, @var2.bind, an_instance_of(Gecode::Raw::IntVar), 
              strength)
            Gecode::Raw.should_receive(:rel).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVar), relation, rhs, strength)
          end
        else
          Gecode::Raw.should_receive(:mult).once.with(
            an_instance_of(Gecode::Raw::Space),
            @var.bind, @var2.bind, an_instance_of(Gecode::Raw::IntVar), strength)
          Gecode::Raw.should_receive(:rel).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVar), relation, rhs, reif_var.bind,
            strength)
        end
      end
    end
  end
  
  it 'should constrain the value of the multiplication' do
    (@var * @var2).must == 56
    sol = @model.solve!
    [sol.var.value, sol.var2.value].sort.should == [7, 8]
  end
  
  it 'should not interfere with other defined multiplication methods' do
    (@var * :foo).should be_nil
  end
  
  it_should_behave_like 'arithmetic constraint'
end