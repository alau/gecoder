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
      @expect.call(relation, target, Gecode::Raw::ICL_DEF, Gecode::Raw::PK_DEF,
        nil, negated)
    end
    
    # For options spec.
    @invoke_options = lambda do |hash|
      @stub.must_be.less_than_or_equal_to(17, hash)
      @model.solve!
    end
    @expect_options = option_expectation do |strength, kind, reif_var|
      @expect.call(Gecode::Raw::IRT_LQ, 17, strength, kind, reif_var, false)
    end
  end
  
  it_should_behave_like 'reifiable constraint'
  it_should_behave_like 'composite constraint'
end

describe Gecode::Constraints::Set::Connection, ' (min)' do
  before do
    @model = Gecode::Model.new
    @set = @model.set_var([], 0..9)
    @target = @var = @model.int_var(0..10)
    @model.branch_on @model.wrap_enum([@set])
    @stub = @set.min
    
    @expect = lambda do |relation, rhs, strength, kind, reif_var, negated|
      @model.allow_space_access do
        rhs = an_instance_of(Gecode::Raw::IntVar) if rhs.respond_to? :bind
        if reif_var.nil?
          if !negated and relation == Gecode::Raw::IRT_EQ and 
              !rhs.kind_of? Fixnum
            Gecode::Raw.should_receive(:min).once.with( 
              an_instance_of(Gecode::Raw::Space),
              an_instance_of(Gecode::Raw::SetVar), rhs)
            Gecode::Raw.should_receive(:rel).exactly(0).times
          else
            Gecode::Raw.should_receive(:min).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::SetVar), 
              an_instance_of(Gecode::Raw::IntVar))
            Gecode::Raw.should_receive(:rel).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVar), relation, rhs, 
              strength, kind)
          end
        else
          Gecode::Raw.should_receive(:min).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::SetVar), 
            an_instance_of(Gecode::Raw::IntVar))
          Gecode::Raw.should_receive(:rel).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVar), relation, rhs, 
            reif_var, strength, kind)
        end
      end
    end
  end
  
  it 'should constrain the min of a set' do
    @set.min.must == 3
    @model.solve!
    @set.lower_bound.min.should == 3
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
    
    @expect = lambda do |relation, rhs, strength, kind, reif_var, negated|
      @model.allow_space_access do
        rhs = an_instance_of(Gecode::Raw::IntVar) if rhs.respond_to? :bind
        if reif_var.nil?
          if !negated and relation == Gecode::Raw::IRT_EQ and 
              !rhs.kind_of? Fixnum
            Gecode::Raw.should_receive(:max).once.with( 
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::SetVar), rhs)
            Gecode::Raw.should_receive(:rel).exactly(0).times
          else
            Gecode::Raw.should_receive(:max).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::SetVar), 
              an_instance_of(Gecode::Raw::IntVar))
            Gecode::Raw.should_receive(:rel).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVar), relation, rhs, 
              strength, kind)
          end
        else
          Gecode::Raw.should_receive(:max).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::SetVar), 
            an_instance_of(Gecode::Raw::IntVar))
          Gecode::Raw.should_receive(:rel).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVar), relation, rhs, 
            reif_var, strength, kind)
        end
      end
    end
  end
  
  it 'should constrain the max of a set' do
    @set.max.must == 3
    @model.solve!
    @set.lower_bound.max.should == 3
  end
  
  it_should_behave_like 'connection constraint'
end

describe Gecode::Constraints::Set::Connection, ' (sum)' do
  before do
    @model = Gecode::Model.new
    @set = @model.set_var([], 0..9)
    @target = @var = @model.int_var(0..20)
    @model.branch_on @model.wrap_enum([@set])
    @stub = @set.sum
    
    @expect = lambda do |relation, rhs, strength, kind, reif_var, negated|
      @model.allow_space_access do
        rhs = an_instance_of(Gecode::Raw::IntVar) if rhs.respond_to? :bind
        if reif_var.nil?
          if !negated and relation == Gecode::Raw::IRT_EQ and 
              !rhs.kind_of? Fixnum
            Gecode::Raw.should_receive(:weights).once.with( 
              an_instance_of(Gecode::Raw::Space), anything, anything, 
              an_instance_of(Gecode::Raw::SetVar), 
              rhs)
            Gecode::Raw.should_receive(:rel).exactly(0).times
          else
            Gecode::Raw.should_receive(:weights).once.with(
              an_instance_of(Gecode::Raw::Space), anything, anything, 
              an_instance_of(Gecode::Raw::SetVar), 
              an_instance_of(Gecode::Raw::IntVar))
            Gecode::Raw.should_receive(:rel).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVar), relation, rhs, 
              strength, kind)
          end
        else
          Gecode::Raw.should_receive(:weights).once.with(
            an_instance_of(Gecode::Raw::Space), 
            anything, anything, an_instance_of(Gecode::Raw::SetVar), 
            an_instance_of(Gecode::Raw::IntVar))
          Gecode::Raw.should_receive(:rel).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVar), relation, rhs, 
            reif_var, strength, kind)
        end
      end
    end
  end
  
  it 'should constrain the sum of a set' do
    @set.sum.must == 7
    @model.solve!.should_not be_nil
    @set.value.inject(0){ |x, y| x + y }.should == 7
  end
  
  it 'should raise error if unsupported options is given' do
    lambda do
      @set.sum(:does_not_exist => :foo).must == @var 
    end.should raise_error(ArgumentError)
  end
  
  it 'should raise error if multiple options are given' do
    lambda do
      @set.sum(:weights => {}, :substitutions => {}).must == @var 
    end.should raise_error(ArgumentError)
  end
  
  it_should_behave_like 'connection constraint'
end

describe Gecode::Constraints::Set::Connection, ' (sum with weights)' do
  before do
    @model = Gecode::Model.new
    @set = @model.set_var([], 0..9)
    @target = @var = @model.int_var(-20..20)
    @model.branch_on @model.wrap_enum([@set])
    @weights = Hash[*(0..9).zip((-9..-0).to_a.reverse).flatten]
    @stub = @set.sum(:weights => @weights)
    
    @expect = lambda do |relation, rhs, strength, kind, reif_var, negated|
      @model.allow_space_access do
        rhs = an_instance_of(Gecode::Raw::IntVar) if rhs.respond_to? :bind
        if reif_var.nil?
          if !negated and relation == Gecode::Raw::IRT_EQ and 
              !rhs.kind_of? Fixnum
            Gecode::Raw.should_receive(:weights).once.with( 
              an_instance_of(Gecode::Raw::Space), anything, anything, 
              an_instance_of(Gecode::Raw::SetVar), rhs)
            Gecode::Raw.should_receive(:rel).exactly(0).times
          else
            Gecode::Raw.should_receive(:weights).once.with(
              an_instance_of(Gecode::Raw::Space), anything, anything, 
              an_instance_of(Gecode::Raw::SetVar), 
              an_instance_of(Gecode::Raw::IntVar))
            Gecode::Raw.should_receive(:rel).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVar), relation, rhs, 
              strength, kind)
          end
        else
          Gecode::Raw.should_receive(:weights).once.with(
            an_instance_of(Gecode::Raw::Space), 
            anything, anything, an_instance_of(Gecode::Raw::SetVar), 
            an_instance_of(Gecode::Raw::IntVar))
          Gecode::Raw.should_receive(:rel).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVar), relation, rhs, 
            reif_var, strength, kind)
        end
      end
    end
  end
  
  it 'should constrain the sum of a set' do
    @stub.must_be.in(-10..-1)
    @model.solve!.should_not be_nil
    weighted_sum = @set.value.inject(0){ |sum, x| sum - x**2 }
    weighted_sum.should >= -10
    weighted_sum.should <= -1
  end
  
  it 'should remove any elements not in the weight hash' do
    @set.sum(:weights => {}).must_be == 0
    @model.solve!.should_not be_nil
    @set.value.size.should be_zero
  end
  
  it_should_behave_like 'connection constraint'
end

describe Gecode::Constraints::Set::Connection, ' (sum with substitutions)' do
  before do
    @model = Gecode::Model.new
    @set = @model.set_var([], 0..9)
    @target = @var = @model.int_var(-20..20)
    @model.branch_on @model.wrap_enum([@set])
    @subs = Hash[*(0..9).zip((-9..-0).to_a.reverse).flatten]
    @stub = @set.sum(:substitutions => @subs)
    
    @expect = lambda do |relation, rhs, strength, kind, reif_var, negated|
      @model.allow_space_access do
        rhs = an_instance_of(Gecode::Raw::IntVar) if rhs.respond_to? :bind
        if reif_var.nil?
          if !negated and relation == Gecode::Raw::IRT_EQ and 
              !rhs.kind_of? Fixnum
            Gecode::Raw.should_receive(:weights).once.with( 
              an_instance_of(Gecode::Raw::Space), anything, anything, 
              an_instance_of(Gecode::Raw::SetVar), rhs)
            Gecode::Raw.should_receive(:rel).exactly(0).times
          else
            Gecode::Raw.should_receive(:weights).once.with(
              an_instance_of(Gecode::Raw::Space), anything, anything, 
              an_instance_of(Gecode::Raw::SetVar), 
              an_instance_of(Gecode::Raw::IntVar))
            Gecode::Raw.should_receive(:rel).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVar), relation, rhs, 
              strength, kind)
          end
        else
          Gecode::Raw.should_receive(:weights).once.with(
            an_instance_of(Gecode::Raw::Space), 
            anything, anything, an_instance_of(Gecode::Raw::SetVar), 
            an_instance_of(Gecode::Raw::IntVar))
          Gecode::Raw.should_receive(:rel).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVar), relation, rhs, 
            reif_var, strength, kind)
        end
      end
    end
  end
  
  it 'should constrain the sum of a set' do
    @stub.must_be.in(-10..-1)
    @model.solve!.should_not be_nil
    substituted_sum = @set.value.inject{ |sum, x| sum + @subs[x] }
    substituted_sum.should >= -10
    substituted_sum.should <= -1
  end
  
  it_should_behave_like 'connection constraint'
end

describe Gecode::Constraints::Set::Connection, ' (include)' do
  before do
    @model = Gecode::Model.new
    @set = @model.set_var([], 2..5)
    @array = @model.int_var_array(4, 0..9)
    @array.must_be.distinct
    @model.branch_on @array
    #@model.branch_on @model.wrap_enum([@set])
    
    @expect = lambda do |rhs, strength, reif_var|
      @model.allow_space_access do
        Gecode::Raw.should_receive(:match).once.with(
          an_instance_of(Gecode::Raw::Space), 
          an_instance_of(Gecode::Raw::SetVar), 
          an_instance_of(Gecode::Raw::IntVarArray))
      end
    end
    
    @expect_options = option_expectation do |strength, kind, reif_var|
      @expect.call(@array, strength, reif_var)
    end
    @invoke_options = lambda do |hash|
      @set.must.include(@array, hash)
      @model.solve!
    end
  end
  
  it 'should translate to a match constraint' do
    @expect_options.call({})
    @set.must.include @array
    @model.solve!
  end
  
  it 'should constrain the variables to be included in the set' do
    @set.must.include @array
    @model.solve!.should_not be_nil
    @array.all?{ |x| @set.lower_bound.include? x.value }.should be_true
  end
  
  it 'should raise error if the right hand side is not an array of variables' do
    lambda{ @set.must.include 'hello' }.should raise_error(TypeError)
  end
  
  it 'should raise error if negated' do
    lambda{ @set.must_not.include @array }.should raise_error(
      Gecode::MissingConstraintError)
  end
  
  it_should_behave_like 'non-reifiable set constraint'
end
