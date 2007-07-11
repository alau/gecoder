require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

describe Gecode::Constraints::Set::Cardinality, ' (range)' do
  before do
    @model = Gecode::Model.new
    @set = @model.set_var([], 0..10)
    @model.branch_on @model.wrap_enum([@set])
    @range = 1..2
    @three_dot_range = 1...2
    
    @invoke_options = lambda do |hash| 
      @set.size.must_be.in(@range, hash) 
    end
    
    @invoke = lambda do |rhs| 
      @set.size.must_be.in(rhs) 
      @model.solve!
    end
    @expect = lambda do |rhs|
      Gecode::Raw.should_receive(:cardinality).once.with(@model.active_space, 
        @set.bind, rhs.first, rhs.last)
    end
  end
  
  it 'should translate cardinality constraints with ranges' do
    @expect.call(@range)
    @invoke.call(@range)
  end

  it 'should translate cardinality constraints with three dot range domains' do
    @expect.call(@three_dot_range)
    @invoke.call(@three_dot_range)
  end
  
  it 'should constrain the cardinality of a set' do
    @set.size.must_be.in @range
    @model.solve!
    @range.should include(@set.val_size)
  end
  
  it 'should raise error if the right hand side is not a range' do
    lambda{ @set.size.must_be.in 'hello' }.should raise_error(TypeError)
  end
  
  it 'should not shadow the integer variable domain constrain' do
    Gecode::Raw.should_receive(:dom).once.with(@model.active_space, 
      an_instance_of(Gecode::Raw::IntVar), an_instance_of(Gecode::Raw::IntSet), 
      Gecode::Raw::ICL_DEF)
    @set.size.must_not_be.in [1,3]
  end
  
  it_should_behave_like 'non-reifiable set constraint'
end

describe Gecode::Constraints::Set::Cardinality, ' (composite)' do
  before do
    @model = Gecode::Model.new
    @set = @model.set_var([], 0..10)
    @target = @var = @model.int_var(0..11)
    @model.branch_on @model.wrap_enum([@set])
    @model.branch_on @model.wrap_enum([@var])
    
    @invoke_options = lambda do |hash| 
      @set.size.must_be.equal_to(@var, hash) 
    end
    
    @invoke = lambda do |rhs| 
      @set.size.must == rhs 
      @model.solve!
    end
    @expect = lambda do |relation, rhs, strength, reif_var, negated|
      rhs = rhs.bind if rhs.respond_to? :bind
      if reif_var.nil?
        if !negated and relation == Gecode::Raw::IRT_EQ and 
            rhs.kind_of? Gecode::Raw::IntVar 
          Gecode::Raw.should_receive(:cardinality).once.with(
            @model.active_space, @set.bind, rhs)
          Gecode::Raw.should_receive(:rel).exactly(0).times
        else
          Gecode::Raw.should_receive(:cardinality).once.with(
            @model.active_space, @set.bind, an_instance_of(Gecode::Raw::IntVar))
          Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
            an_instance_of(Gecode::Raw::IntVar), relation, rhs, 
            strength)
        end
      else
        Gecode::Raw.should_receive(:cardinality).once.with(@model.active_space, 
          @set.bind, an_instance_of(Gecode::Raw::IntVar))
        Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVar), relation, rhs, reif_var.bind,
          strength)
      end
    end
    
    # For composite spec.
    @invoke_relation = lambda do |relation, target, negated|
      if negated
        @set.size.must_not.send(relation, target)
      else
        @set.size.must.send(relation, target)
      end
      @model.solve!
    end
    @expect_relation = lambda do |relation, target, negated|
      @expect.call(relation, target, Gecode::Raw::ICL_DEF, nil, negated)
    end
    
    # For options spec.
    @invoke_options = lambda do |hash|
      @set.size.must_be.less_than_or_equal_to(17, hash)
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      @expect.call(Gecode::Raw::IRT_LQ, 17, strength, reif_var, false)
    end
  end
  
  it 'should constrain the cardinality of a set' do
    @set.size.must == @var
    @model.solve!
    @set.val_size.should == @var.val
  end
  
  it_should_behave_like 'constraint with options'
  it_should_behave_like 'composite constraint'
end
