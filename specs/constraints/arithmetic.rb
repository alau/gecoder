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

# Construct a method placing expectations for an arithmetic constraint with the 
# specified arity (number of variables before must) and the specified name in 
# Gecode.   
def arithmetic_expectation(gecode_name, arity)
  lambda do |relation, rhs, strength, kind, reif_var, negated|
    # Construct the arguments expected to be passed to the Gecode variant of 
    # the constraint.
    rhs = an_instance_of(Gecode::Raw::IntVar) if rhs.respond_to? :bind
    expected_gecode_arguments = [an_instance_of(Gecode::Raw::Space)]
    arity.times do
      expected_gecode_arguments << an_instance_of(Gecode::Raw::IntVar)
    end
    can_use_single_gecode_constraint = reif_var.nil? && !negated && 
      relation == Gecode::Raw::IRT_EQ && !rhs.kind_of?(Fixnum)
    if can_use_single_gecode_constraint
      expected_gecode_arguments << rhs
    else
      expected_gecode_arguments << an_instance_of(Gecode::Raw::IntVar)
    end
    expected_gecode_arguments.concat([strength, kind])
    
    # Create the actual method producing the expectation.
    @model.allow_space_access do
      if reif_var.nil?
        if can_use_single_gecode_constraint
          Gecode::Raw.should_receive(gecode_name).once.with(
            *expected_gecode_arguments)
          Gecode::Raw.should_receive(:rel).exactly(0).times
        else
          Gecode::Raw.should_receive(gecode_name).once.with(
            *expected_gecode_arguments)
          Gecode::Raw.should_receive(:rel).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVar), 
            relation, rhs, strength, kind)
        end
      else
        Gecode::Raw.should_receive(gecode_name).once.with(
          *expected_gecode_arguments)
        Gecode::Raw.should_receive(:rel).once.with(
          an_instance_of(Gecode::Raw::Space), 
          an_instance_of(Gecode::Raw::IntVar), relation, rhs, 
          an_instance_of(Gecode::Raw::BoolVar),
          strength, kind)
      end
    end
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
    @expect_options = option_expectation do |strength, kind, reif_var|
      @expect.call(Gecode::Raw::IRT_GR, @target, strength, kind, reif_var, 
        false)
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
      @expect.call(relation, target, Gecode::Raw::ICL_DEF, Gecode::Raw::PK_DEF,
        nil, negated)
    end
  end
  
  it 'should translate reification when using equality' do
    bool_var = @model.bool_var
    @expect.call(Gecode::Raw::IRT_EQ, @target, Gecode::Raw::ICL_DEF, 
      Gecode::Raw::PK_DEF, bool_var, false)
    @stub.must_be.equal_to(@target, :reify => bool_var)
    @model.solve!
  end
  
  it_should_behave_like 'composite constraint'
  it_should_behave_like 'reifiable constraint'
end

describe Gecode::Constraints::IntEnum::Arithmetic, ' (max)' do
  before do
    @model = ArithmeticSampleProblem.new
    @numbers = @model.numbers
    @target = @var = @model.var
    @stub = @numbers.max
    
    # Creates an expectation corresponding to the specified input.
    @expect = lambda do |relation, rhs, strength, kind, reif_var, negated|
      @model.allow_space_access do
        rhs = an_instance_of(Gecode::Raw::IntVar) if rhs.respond_to? :bind
        if reif_var.nil?
          if !negated and relation == Gecode::Raw::IRT_EQ and 
              !rhs.kind_of? Fixnum
            Gecode::Raw.should_receive(:max).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVarArray), 
              rhs, strength, kind)
            Gecode::Raw.should_receive(:rel).exactly(0).times
          else
            Gecode::Raw.should_receive(:max).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVarArray), 
              an_instance_of(Gecode::Raw::IntVar), 
              strength, kind)
            Gecode::Raw.should_receive(:rel).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVar), 
              relation, rhs, strength, kind)
          end
        else
          Gecode::Raw.should_receive(:max).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVarArray), 
            an_instance_of(Gecode::Raw::IntVar), 
            strength, kind)
          Gecode::Raw.should_receive(:rel).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVar), relation, rhs, 
            an_instance_of(Gecode::Raw::BoolVar),
            strength, kind)
        end
      end
    end
  end
  
  it 'should constrain the maximum value' do
    @numbers.max.must > 5
    @model.solve!.numbers.values.max.should > 5
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
    @expect = lambda do |relation, rhs, strength, kind, reif_var, negated|
      @model.allow_space_access do
        rhs = an_instance_of(Gecode::Raw::IntVar) if rhs.respond_to? :bind
       if reif_var.nil?
          if !negated and relation == Gecode::Raw::IRT_EQ and 
              !rhs.kind_of? Fixnum
            Gecode::Raw.should_receive(:min).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVarArray), 
              rhs, strength, kind)
            Gecode::Raw.should_receive(:rel).exactly(0).times
          else
            Gecode::Raw.should_receive(:min).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVarArray), 
              an_instance_of(Gecode::Raw::IntVar), 
              strength, kind)
            Gecode::Raw.should_receive(:rel).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVar), 
              relation, rhs, strength, kind)
          end
        else
          Gecode::Raw.should_receive(:min).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVarArray), 
            an_instance_of(Gecode::Raw::IntVar), 
            strength, kind)
          Gecode::Raw.should_receive(:rel).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVar), relation, rhs, 
            an_instance_of(Gecode::Raw::BoolVar),
            strength, kind)
        end
      end
    end
  end
  
  it 'should constrain the minimum value' do
    @numbers.min.must > 5
    @model.solve!.numbers.values.min.should > 5
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
    @expect = lambda do |relation, rhs, strength, kind, reif_var, negated|
      @model.allow_space_access do
        rhs = an_instance_of(Gecode::Raw::IntVar) if rhs.respond_to? :bind
        if reif_var.nil?
          if !negated and relation == Gecode::Raw::IRT_EQ and 
              !rhs.kind_of? Fixnum
            Gecode::Raw.should_receive(:abs).once.with(
              an_instance_of(Gecode::Raw::Space),
              an_instance_of(Gecode::Raw::IntVar), 
              rhs, strength, kind)
            Gecode::Raw.should_receive(:rel).exactly(0).times
          else
            Gecode::Raw.should_receive(:abs).once.with(
              an_instance_of(Gecode::Raw::Space),
              an_instance_of(Gecode::Raw::IntVar), 
              an_instance_of(Gecode::Raw::IntVar), 
              strength, kind)
            Gecode::Raw.should_receive(:rel).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVar), 
              relation, rhs, strength, kind)
          end
        else
          Gecode::Raw.should_receive(:abs).once.with(
            an_instance_of(Gecode::Raw::Space),
            an_instance_of(Gecode::Raw::IntVar), 
            an_instance_of(Gecode::Raw::IntVar), 
            strength, kind)
          Gecode::Raw.should_receive(:rel).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVar), relation, rhs, 
            an_instance_of(Gecode::Raw::BoolVar), 
            strength, kind)
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
    
    @expect = arithmetic_expectation(:mult, 2)
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

describe Gecode::Constraints::Int::Arithmetic, ' (squared)' do
  before do
    @model = ArithmeticSampleProblem.new
    @var = @model.var
    @stub = @var.squared
    @target = @model.var2
    
    @expect = arithmetic_expectation(:sqr, 1)
  end
  
  it 'should constrain the value of the variable squared' do
    @var.squared.must == 9
    sol = @model.solve!
    sol.var.value.abs.should == 3
  end
  
  it_should_behave_like 'arithmetic constraint'
end

describe Gecode::Constraints::Int::Arithmetic, ' (square root)' do
  before do
    @model = ArithmeticSampleProblem.new
    @var = @model.var
    @stub = @var.square_root
    @target = @model.var2
    
    @expect = arithmetic_expectation(:sqrt, 1)
  end
  
  it 'should constrain the square root of the variable' do
    @var.square_root.must == 3
    sol = @model.solve!
    Math.sqrt(sol.var.value).floor.should == 3
  end
  
  it 'should constrain the square root of the variable (2)' do
    @var.square_root.must == 0
    sol = @model.solve!
    Math.sqrt(sol.var.value).floor.should == 0
  end
  
  it 'should constrain the square root of the variable (3)' do
    @var.must < 0
    @var.square_root.must == 0
    @model.solve!.should be_nil
  end
  
  it 'should round down the square root' do
    @var.must > 4
    @var.square_root.must == 2
    sol = @model.solve!
    sol.var.value.should be_between(5,8)
  end
  
  it_should_behave_like 'arithmetic constraint'
end
