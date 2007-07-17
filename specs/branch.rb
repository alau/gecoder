require File.dirname(__FILE__) + '/spec_helper'

class BranchSampleProblem < Gecode::Model
  attr :vars
  attr :bools
  
  def initialize
    @vars = int_var_array(2, 0..3)
    @bools = bool_var_array(2)
  end
end

describe Gecode::Model, ' (branch)' do
  before do
    @model = BranchSampleProblem.new
    @vars = @model.vars
    @bools = @model.bools
  end

  it 'should default to :none and :min' do
    Gecode::Raw.should_receive(:branch).once.with(
      an_instance_of(Gecode::Raw::Space), 
      anything, Gecode::Raw::BVAR_NONE, Gecode::Raw::BVAL_MIN)
    @model.branch_on @vars
    @model.solve!
  end
  
  it 'should ensure that branched int variables are assigned in a solution' do
    @model.branch_on @vars
    @model.solve!.vars.each{ |var| var.should be_assigned }
  end
  
  it 'should ensure that branched bool variables are assigned in a solution' do
    @model.branch_on @bools
    @model.solve!.bools.each{ |var| var.should be_assigned }
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
      Gecode::Raw.should_receive(:branch).once.with(
        an_instance_of(Gecode::Raw::Space),
        anything, gecode_const, an_instance_of(Numeric))
      @model.branch_on @vars, :variable => name
      @model.solve!
    end
  end

  supported_val_selectors = {
    :min        => Gecode::Raw::BVAL_MIN,
    :med        => Gecode::Raw::BVAL_MED,
    :max        => Gecode::Raw::BVAL_MAX,
    :split_min  => Gecode::Raw::BVAL_SPLIT_MIN,
    :split_max  => Gecode::Raw::BVAL_SPLIT_MAX
  }.each_pair do |name, gecode_const|
    it "should support #{name} as value selection strategy" do
      Gecode::Raw.should_receive(:branch).once.with(
        an_instance_of(Gecode::Raw::Space), 
        anything, an_instance_of(Numeric), gecode_const)
      @model.branch_on @vars, :value => name
      @model.solve!
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