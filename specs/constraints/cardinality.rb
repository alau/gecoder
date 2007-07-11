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
  
  it 'should raise error if negated' do
    lambda{ @set.size.must_not_be.in @range }.should raise_error(
      Gecode::MissingConstraintError)
  end
  
  it 'should raise error if the right hand side is not a range' do
    lambda{ @set.size.must_be.in 'hello' }.should raise_error(TypeError)
  end
  
  it_should_behave_like 'non-reifiable set constraint'
end