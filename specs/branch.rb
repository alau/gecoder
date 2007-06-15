require File.dirname(__FILE__) + '/spec_helper'

class BranchSampleProblem < Gecode::Model
  attr :vars
  
  def initialize
    super()

    @vars = int_var_array(2, 0..3)
  end
end

describe Gecode::Model, ' (branch)' do
  before do
    @model = BranchSampleProblem.new
    @vars = @model.vars
  end

  it 'should pass the variables given' do
    Gecode::Raw.should_receive(:branch).once.and_return{ |s, vars, x, y| vars }
    int_var_array = @model.branch_on @vars
    int_var_array.size.should equal(2)
    2.times do |i|
      int_var_array.at(i).should have_domain(0..3)
    end
  end

  it 'should default to :none and :min' do
    Gecode::Raw.should_receive(:branch).once.with(@model.active_space, 
      anything, Gecode::Raw::BVAR_NONE, Gecode::Raw::BVAL_MIN)
    @model.branch_on @vars
  end

  supported_var_selectors = {
    :none                 => Gecode::Raw::BVAR_NONE,
    :smallest_min         => Gecode::Raw::BVAR_MIN_MIN,
    :largest_min          => Gecode::Raw::BVAR_MIN_MAX, 
    :smallest_max         => Gecode::Raw::BVAR_MAX_MIN, 
    :largest_max          => Gecode::Raw::BVAR_MAX_MAX, 
    :smallest_size        => Gecode::Raw::BVAR_SIZE_MIN, 
    :largest_size         => Gecode::Raw::BVAR_SIZE_MAX,
    :smallest_degree      => Gecode::Raw::BVAR_DEGREE_MIN, 
    :largest_degree       => Gecode::Raw::BVAR_DEGREE_MAX, 
    :smallest_min_regret  => Gecode::Raw::BVAR_REGRET_MIN_MIN,
    :largest_min_regret   => Gecode::Raw::BVAR_REGRET_MIN_MAX,
    :smallest_max_regret  => Gecode::Raw::BVAR_REGRET_MAX_MIN, 
    :largest_max_regret   => Gecode::Raw::BVAR_REGRET_MAX_MAX
  }.each_pair do |name, gecode_const|
    it "should support #{name} as variable selection strategy" do
      Gecode::Raw.should_receive(:branch).once.with(@model.active_space, 
        anything, gecode_const, an_instance_of(Numeric))
      @model.branch_on @vars, :variable => name
    end
  end

  supported_val_selectors = {
    :min        => Gecode::Raw::BVAL_MIN,
    :med        => Gecode::Raw::BVAL_MED,
    :max        => Gecode::Raw::BVAL_MAX,
    :split_min  => Gecode::Raw::BVAL_SPLIT_MIN,
    :split_max  => Gecode::Raw::BVAL_SPLIT_MAX
  }.each_pair do |name, gecode_const|
    it "it should support #{name} as value selection strategy" do
      Gecode::Raw.should_receive(:branch).once.with(@model.active_space, 
        anything, an_instance_of(Numeric), gecode_const)
      @model.branch_on @vars, :value => name
    end
  end

  it 'should raise errors for unrecognized var selection strategies' do
    lambda do 
      @model.branch_on @vars, :variable => :foo 
    end.should raise_error(ArgumentError)
  end
  
  it 'should raise errors for unrecognized val selection strategies' do
    lambda do 
      @model.branch_on @vars, :value => :foo 
    end.should raise_error(ArgumentError)
  end

  it 'should raise errors for unrecognized options' do
    lambda do
      @model.branch_on @vars, :foo => 5 
    end.should raise_error(ArgumentError)
  end
end